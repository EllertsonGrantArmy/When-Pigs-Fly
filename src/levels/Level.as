package levels
{
	import citrus.core.starling.StarlingState;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.nape.Hero;
	import citrus.physics.nape.Nape;
	
	import flash.events.DataEvent;
	import flash.events.TimerEvent;
	import flash.net.XMLSocket;
	import flash.utils.Timer;
	
	import nape.callbacks.InteractionCallback;
	
	import objects.JumpingHero;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class Level extends StarlingState
	{
		
		
		private var socket:XMLSocket;	//connection for pressure sensor
		private const PORT:int = 5331;	//port number for connecting to pressure sensor
		private const LOCALHOST:String = "127.0.0.1";	//host for pressure sensor connection
		
		public var paused:Boolean = false;	//is the game paused
		
		public var scoreText:TextField;	//holds int representing score
		
		private var start:Button;			//start game button
		private var ready:Image;			//ready? go!!
		private var pauseBtn:Button;		//pause button in header
		private var resumeBtn:Button;		//resume button in header
		private var tweenText:Tween;		//used to tween ready text across creen
		private var homeBtn:Button;			//go home button
		private var resumeStgBtn:Button; 	//resume button on stage
		
		private var gamePausedImg:Image;	//"game paused" textual image
		public var livesText:TextField;		//textfield in header showing number of remaining lives
		public var _remainingLives:int;	// number of lives remaining at the start of the level
		protected var instructions:TextField;	//textfield holding instructions at beginning of level
		
		public var _countSeconds:int;	//number of seconds in level
		public var myTimer:Timer;		//timer to countdown seconds in level
		public var timeRemainingText:TextField;		//textfield showing the number of seconds left in the level
		
		private var background:Image;	//blue sky background image
		protected var endLevelReason:TextField; //textfield to display reason for level failed
		
		public function Level()
		{
			//call the super (StarlingState)'s constructor 
			super();
		}
		
		override public function initialize():void {
			//call the super (StarlingState)'s initialize 
			super.initialize();
			
			//get all visuals in assets texture atlas
			Assets.init();
			
			
			/**
			 * physics engine
			 * */
			var _nape:Nape = new Nape("nape");
			_nape.visible = false; //don't want to see physics objects' outlines
			add(_nape); //add to stage
			
			
			/**
			 * background image
			 * */
			background = new Image(Assets.backT);	//blue sky
			addChildAt(background, 0);	//add to stage at lowest z-index
						
			/**
			 * instructions textfield
			 * */
			instructions = new TextField(stage.stageWidth, 150, "", "arial", 26, 0xffffff, false);
			instructions.x = 0;	//positioning x
			instructions.y = stage.stageHeight/2 - 70;	//positioning y
			instructions.hAlign = HAlign.CENTER;	//center text in textfield
			instructions.vAlign = VAlign.TOP;		//top align text in textfield
			addChild(instructions);					//add it to the stage
			
			/**
			 * reason for failing the level
			 * */
			endLevelReason = new TextField(stage.stageWidth, 50, "", "arial", 24, 0xffffff, false);
			endLevelReason.x = 0;
			endLevelReason.hAlign = HAlign.CENTER;	//center text in textfield
			endLevelReason.vAlign = VAlign.TOP;		//top align text in textfield
			
			/**
			 * start game button
			 * */
			start = new Button(Assets.ta.getTexture("startBtn"));
			start.x = stage.stageWidth/2 - start.width/2;	//positioning x
			start.y = stage.stageHeight/2;	//positioning y
			addChild(start);	//add button to stage
			start.addEventListener(TouchEvent.TOUCH, showReadyText);	//when clicked, show "ready? go!" text
					
			
			/**
			 * resume game button that's on the stage (rather than header)
			 * */
			resumeStgBtn = new Button(Assets.ta.getTexture("resumeBtn"));
			resumeStgBtn.x = stage.stageWidth/2;
			resumeStgBtn.y = 250;
			resumeStgBtn.addEventListener(TouchEvent.TOUCH, pauseResumeGame); //when clicked, resume game
			
			
			/**
			 * green header information bar
			 * */
			var header:Image = new Image(Assets.ta.getTexture("header"));
			header.x = 0;
			header.y = header.x;
			addChild(header);	//add to stage
			
			/**
			 * textfield showing current score
			 * */
			scoreText = new TextField(150, 25, "", "Arial", 16, 0xffffff, false);			
			scoreText.x = 60;
			scoreText.y = 3;
			scoreText.hAlign = HAlign.LEFT;	//align text of textfield to left
			addChild(scoreText);	//add to stage
			
			/**
			 * time remaining in level textfield
			 * */
			timeRemainingText = new TextField(150, 25, String(_countSeconds), "Arial", 16, 0xffffff, false);
			timeRemainingText.x = stage.stageWidth/2 - 30;
			timeRemainingText.y = scoreText.y;
			addChild(timeRemainingText);
			
			/**
			 * small image of pig's head representing number of lives left
			 * */
			var livesImage:Image = new Image(Assets.ta.getTexture("livesHead"));
			livesImage.y = 4;
			livesImage.x = stage.stageWidth - 105; 
			addChild(livesImage); //add to stage
			
			/**
			 * textfield showing how many lives are left
			 * */
			livesText = new TextField(50, 25, "x", "Arial", 17, 0xffffff, false);
			livesText.x = livesImage.x - 40;
			livesText.y = scoreText.y;
			addChild(livesText); 	//add to stage
			
			/**
			 * pause button in header bar
			 * */
			pauseBtn = new Button(Assets.ta.getTexture("pauseText"));
			pauseBtn.x = 434;
			pauseBtn.y = 2;
			addChild(pauseBtn);		//add to stage
			
			/**
			 * resume button in header bar
			 * */
			resumeBtn = new Button(Assets.ta.getTexture("resumeText"));
			resumeBtn.x = pauseBtn.x;
			resumeBtn.y = pauseBtn.y;
			resumeBtn.visible = false;	//don't want this shown right away
			addChild(resumeBtn);	//add to stage
			
			/**
			 * "game paused" textual image
			 * */
			gamePausedImg = new Image(Assets.ta.getTexture("gamePaused"));
			gamePausedImg.x = stage.stageWidth /2 - gamePausedImg.width/2;
			gamePausedImg.y = 125;
			
			/**
			 * home button that brings the users back to home screen
			 * */
			homeBtn = new Button(Assets.ta.getTexture("homeBtn"));
			homeBtn.x = stage.stageWidth/2;
			homeBtn.y = 325;
			homeBtn.addEventListener(TouchEvent.TOUCH, goHome);
		}
		
		//slide "ready? go!!" text on screen when user clicks the start button
		private function showReadyText(e:TouchEvent):void{
			
			var touch:Touch = e.getTouch(this, TouchPhase.BEGAN);
			
			//if touch began
			if (touch){
				
				removeChild(start);			//remove start button	
				removeChild(instructions);	//remove instructions
				
				//"ready? go!" textual image
				ready = new Image(Assets.ta.getTexture("readyText"));
				ready.x = -200;	
				ready.y = stage.stageHeight/2;
				addChild(ready);
				
				//tweens the "ready? go!" text to the middle of the stage
				tweenText = new Tween(ready, 2.25, Transitions.EASE_OUT_BACK);
				tweenText.animate("x", stage.stageWidth/2 - ready.width/2);	//change x position of text
				tweenText.onComplete = openSocket; 	//when done tweening, call openSocket() function
				Starling.juggler.add(tweenText);	//add stween to juggler in order for it to animate
			}
		}
		
		private function openSocket():void {
			
			//tween ready off screen
			tweenText = new Tween(ready, .75, Transitions.EASE_IN_BACK);
			tweenText.animate("x", stage.stageWidth*2); //change x position of text to the right of the stage
			tweenText.onComplete = startGame;	//when done tweening, call startGame() function
			Starling.juggler.add(tweenText);	//add stween to juggler in order for it to animate
			
			socket = new XMLSocket();		//initialize socket connection
			socket.addEventListener(DataEvent.DATA, onDataReceived);	//when receiving data, call onDataRecie
			socket.connect(LOCALHOST, PORT);		//connect to the localhost with corresponding port number
			
		}
		
		//called when finished tweening "ready? go!" text off screen
		public function startGame():void
		{	
			removeChild(ready);		//remove "ready? go!" text
			
			myTimer = new Timer(1000, _countSeconds);	//initialize timer to 1000 miliseconds, going _countSeconds number of times
			myTimer.addEventListener(TimerEvent.TIMER, countdown);	//call countown() function every 1000 miliseconds
			myTimer.start();	//start the timer
			
			//add event listeners to pause and resume buttons
			pauseBtn.addEventListener(TouchEvent.TOUCH, pauseResumeGame);	
			resumeBtn.addEventListener(TouchEvent.TOUCH, pauseResumeGame);
			
			paused = false; 	//game is no longer paused
		}
		
		//called when user presses home button
		private function goHome(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(this, TouchPhase.BEGAN);
			if (touch)//if touch began
				JumpingGame.ref.switchState("HOME");	//change state to home screen state
		}
		
		//called when user presses restart button after losing all 5 lives
		private function restartGame(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(this, TouchPhase.BEGAN);
			if (touch)//if touch began
				JumpingGame.ref.switchState("GAMEPLAY");	//change state to new instance of level one
		}
		
		public function countdown(event:TimerEvent):void
		{
			//update the timeRemaining textfield to current time remaining on myTimer
			timeRemainingText.text = String((_countSeconds)-myTimer.currentCount);			
			
			//if the user is out of time, end the level with its "passed" parameter as false
			if(timeRemainingText.text == "0")
				endLevel(false, "time");
		}
		
		public function onDataReceived(event:DataEvent):void {
			//when receiving data from pressure sensor (which is constantly unless the socket is closed)
			//to be filled in by sub classes later
		}
		
		public function pauseResumeGame(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(this, TouchPhase.BEGAN);
			
			//if clicked pause button and the game is not paused
			if (touch && !paused){	
				
				paused = true;				//pause game
				
				myTimer.stop();				//pause the timer
				
				pauseBtn.visible = false;	//hide pause button on stage
				resumeBtn.visible = true;	//show resume button on stage
				
				addChild(gamePausedImg);	//add "game paused" textual image
				addChild(homeBtn);			//add "go home" button
				addChild(resumeStgBtn);		//add resume button to stage
				if(socket.connected)
				socket.close();				//close the socket
			}
			
			//if clicked resume button and the game is paused
			else if(touch && paused){
				
				paused = false;			//unpause the game
				
				myTimer.start();		//restart the timer
				
				resumeBtn.visible = false; //hide resume button on stage
				pauseBtn.visible = true;  //show pause button on stage again
				
				removeChild(gamePausedImg);	//remove "game paused" textual image from stage
				removeChild(homeBtn);		//remove home button from stage
				removeChild(resumeStgBtn);	//remove resume button from stage
				
				if(!socket.connected)
				socket.connect(LOCALHOST, PORT);	//reconnect to socket
			}
		}
		
		public function endLevel(passed:Boolean, reason:String):void
		{
			
			//if level completed successfully 
			if(passed){
				
				//create and add level complete textual image
				var levelCompleteImage:Image = new Image(Assets.ta.getTexture("levelComplete"));
				levelCompleteImage.x = 85; //position it in the center of the stage
				levelCompleteImage.y = 125;
				addChild(levelCompleteImage);	//add to stage
			}
				
			//if level failed
			else {
				
				_remainingLives--; //reduce number of remaining lives
				livesText.text = "x" + _remainingLives.toString(); //update remaining lives textfield	
				
				//create and add level failed textual image
				var levelFailedImage:Image;
				if(_remainingLives == 0)
					levelFailedImage = new Image(Assets.ta.getTexture("gameOver"));
				else 
					levelFailedImage = new Image(Assets.ta.getTexture("levelFailed"));
				levelFailedImage.x = 135;
				levelFailedImage.y = 125;
				addChild(levelFailedImage);	//add to stage
			}
			
			switch(reason){
				case "bird":
					endLevelReason.text = "Hit three birds.";
					break;
				case "time":
					endLevelReason.text = "Out of time.";
					break;
				case "height":
					endLevelReason.text = "Fell too far.";
					break;
				case "passed":
					endLevelReason.text = "+" + timeRemainingText.text + " points for beating the clock!";
					break;
			}
			endLevelReason.y = 190;
			addChild(endLevelReason);
			
			
			myTimer.stop(); //stop timer
			paused = true;	//"pause" game
			
			//remove event listener from pause button so the user can't pause the game anymore
			pauseBtn.removeEventListener(TouchEvent.TOUCH, pauseResumeGame);
						
			//add home button to the stage
			addChild(homeBtn);
			
			
			//close socket to prevent jumping 
			//have to check if it's connected first to prevent closing an already closed socket error
			if(socket.connected)
				socket.close();
		}
		
		
		override public function update(timeDelta:Number):void
		{
			//if game is not paused, call super (StarlingState)'s update() function
			if(!paused)
				super.update(timeDelta);
		}
		
	}
}