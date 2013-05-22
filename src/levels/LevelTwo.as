package levels
{
	import citrus.math.MathVector;
	import citrus.objects.platformer.nape.Platform;
	
	import flash.events.DataEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	
	import nape.callbacks.InteractionCallback;
	import nape.geom.Vec2;
	import nape.phys.BodyType;
	
	import objects.Apple;
	import objects.Bird;
	import objects.FlyingHero;
	import objects.HillsManagingGraphics;
	import objects.HillsTexture;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.deg2rad;
	
	import states.CalibrateState;

	public class LevelTwo extends Level
	{		
		public var hero:FlyingHero; //flying pig hero
		public var pigMC:MovieClip; //movieclip for animation of pig
		
		private var _currLevel:int;	//current level (2)
		private var _currScore:int;	//current score from previous levels and tries
		private var _startScore:int;//represents the score at the beginning of the level
		
		private var applesEaten:int = 0; //apples eaten, 0 at start of level
		private var apples:Array;		//array to hold apples on stage
		
		private const startX:int = 120; //starting x of the pig and cloud
				
		public static var ref:LevelTwo;	//reference to this class from others
		
		private var cloudPlatform:Platform; //starting platform that pig stands on
		private var hills:HillsManagingGraphics; //specialized hills class
		private var _hillsTexture:HillsTexture;	//shows coloured hills
		
		private var appleText:TextField;	//textfield showing number of apples eaten
		private var canAddApple:Number;
		private var canAddBird:Number;
		private var birds:Array;
		private var X:int = 0;
		private var _calibration:int = 0;
		
		public function LevelTwo(currLevel:int, remainingLives:int, currScore:int, countSeconds:int)
		{
			super(); //calls level's constructor
			
			_currLevel = 		currLevel;
			_remainingLives = 	remainingLives;
			_currScore =	 	currScore;
			_startScore = 		currScore;
			_countSeconds = 	countSeconds;
			
			LevelTwo.ref = this; //reference to this class from other classes
			
			//if the user has gone to and compeleted the calibration state 
			if(CalibrateState.ref)
				_calibration =		CalibrateState.ref.calibration;
				//if not, calibration ability set to 0
			else _calibration = 	0;
		}
		
		override public function initialize():void
		{
			super.initialize();
			paused = true; //level is paused initially
			
			pigMC = new MovieClip(Assets.ta.getTextures("pigWithWings"));
			
			apples = new Array(); //initialize apples array
			birds = new Array();
			
			scoreText.text = _currScore.toString();		//set the score textfield to the current score
			livesText.text += _remainingLives;			//set the lives textfield to the remaining lives
					
			
			/**
			 * apple icon in header bar
			 */
			var appleIcon:Image = new Image(Assets.ta.getTexture("appleCoin"));
			appleIcon.x = 145;
			appleIcon.y = 6;
			appleIcon.scaleX = appleIcon.scaleY = 0.8; //scale apple icon on header
			addChild(appleIcon); //add to stage
			
			
			/**
			 * text field to hold the count of apples caught
			 */
			appleText = new TextField(35, 25, "0", "Salam", 16, 0xffffff, false);
			appleText.x = appleIcon.x + 15;
			appleText.y = 3;
			addChild(appleText); //add to stage
			
			instructions.text = "Collect 100 apples to win\nWatch out for the birds!";
			//update instructions text			
			
			
			/**
			 * create and add hills to stage
			 */
			_hillsTexture = new HillsTexture();
			hills = new HillsManagingGraphics("hills", 
				{sliceHeight:400, sliceWidth:30, widthHills: 1000, currentYPoint:stage.stageHeight/2, registration:"topLeft", view:_hillsTexture});
			add(hills);
			
			
			/**
			 * create and add initial cloud to stage
			 */			
			cloudPlatform = new Platform("invisiblePlat", {x:startX, y: 210, width: 100, height:10, offsetY:-8});
			cloudPlatform.view = new Image(Assets.ta.getTexture("cloud"));
			add(cloudPlatform);
			cloudPlatform.view.scaleX = 0.7;
			cloudPlatform.view.scaleY = 0.5;			
			
			/**
			 * create and add flying pig hero to stage
			 */
			hero = new FlyingHero("hero", {x: startX-38 , y: 130, radius: 45});
			hero.view = pigMC;
			pigMC.stop();
			add(hero);
			//hero.body.gravMass = 0.5;
			hero.body.allowRotation = false;
			hero.offsetY = -25;			
			
			/**
			 * keep the view focused on the pig
			 */ 
			view.camera.setUp(hero, new citrus.math.MathVector(stage.stageWidth/2 -160, (stage.stageHeight / 2) + 150),
				new Rectangle(0, -2500, int.MAX_VALUE, int.MAX_VALUE/2), new MathVector(.05, .25));
			view.camera.allowZoom = true;
			//view.camera.restrictZoom = true;
			//view.camera.zoomEasing = 10;
		}
		
		override public function startGame():void
		{
			//call level's start game(when ready? go! tweened off stage
			super.startGame();	
			
			hero.offsetY = 4;				
			
			remove(cloudPlatform); //remove cloud platform from stage
		}
		
		//when receiving data from sensor
		override public function onDataReceived(event:DataEvent):void
		{
			if(event.data.substr(0,2) == "A0"){
				var data:int = parseInt(event.data);			
				data = parseInt(event.data.substr(2,6));
				
				
				if(hero.y < stage.stageHeight/3 && data > 180)
					view.camera.setZoom(0.8);
				else if(data <= 30 && view.camera.getZoom() <= 0.9)
					view.camera.setZoom(1);
				if(view.camera.getZoom() >= 1.25)
					view.camera.setZoom(1);
			
				data = data/4;
				
				if(_calibration == 0 || (_calibration > 75 && _calibration < 125) ) //if no calibration done or average
					hero._updateAnimation(data);
				else if (_calibration >= 0 && _calibration <= 75) //if user is weak
					hero._updateAnimation(data*1.5);
				else if (_calibration >= 125 && _calibration <= 500) //if user is strong
					hero._updateAnimation(data*0.75);
				
				if(data > 5) pigMC.play();
				else pigMC.stop();
			}
		}
		
		/**
		 * called from Bird when user is hit
		 * */
		public function addX():void
		{
			X++;
			
			var x:Image = new Image(Assets.ta.getTexture("x"));
			x.x = stage.stageWidth - x.width/2 - 25 * X;
			x.y = 45;
			addChild(x);
			
			if(X == 3)
				endLevel(false, "bird");
		}
		
		/**
		 * adds select amount of apples to stage
		 */
		private function addApples():void
		{			
			//create 3 - 8 apples for collection
			var applesToAdd:int = Math.random() * (1 + 8 - 3) + 3;
			for(var i:int = 0; i < applesToAdd; i++)
			{
				var appleCoin:Apple = new Apple("apple", {radius:11}); //create new apple which is subclass of coin
				appleCoin.view = new Image(Assets.ta.getTexture("appleCoin"));
				appleCoin.x = hills.sliceWidth * hills.slicesCreated + i*(hills.sliceWidth*2); 
				
				//positive amplitude = downward hill
				if(hills.currentAmplitude < 0)
					appleCoin.y = hills.currentYPoint + (hills.currentAmplitude * i) - 150;
				else appleCoin.y = hills.currentYPoint - 90;
				
				apples.push(appleCoin); //add apple to apples array
				add(appleCoin); 		//add apple to stage
			}			
		}
		
		private function addBird():void
		{
			trace("adding bird");
			//create a bird "enemy" object
			var randomY:int = Math.floor(Math.random() * (1 + 350 - 100) + 100);
			
			var bird:Bird = new Bird("bird", {x: stage.stageWidth + hills.sliceWidth * hills.slicesCreated, y: hills.currentYPoint - randomY, radius: 25, speed: 45});
			bird.view = new MovieClip(Assets.ta.getTextures("bird"), 2);
			add(bird);			//add the current bird to the stage
			
			bird.body.allowRotation = false;	//bird can't rotate (when hit by pig or coud)
			bird.body.kinematicVel = new Vec2(-1, 1); //keeps bird afloat
			bird.body.type = BodyType.KINEMATIC;	//prevent collision with clouds
			bird.hurtDuration = 1;
			
			birds.push(bird);	//add the current bird to the array
		}
		
		/**
		 * when user collects apple
		 */
		public function eatApple(c:InteractionCallback):void
		{
			apples.pop(); //remove apple from array
			applesEaten++;	//increase number of apples eaten
			scoreText.text = (_currScore+=10).toString(); //update the score text
			appleText.text = applesEaten.toString(); //update number of apples eaten text
			
			/**
			 * if the user collects 100 apples
			 */
			if(applesEaten == 100){
				//add the cloud platform back to stage to the right hand side of stage
				cloudPlatform.x = hero.x + 20;
				add(cloudPlatform);
				
				//fly the pig up to platform
				hero.body.velocity.y -= 15;
								
				endLevel(true, "passed"); //call end level with "passed" parameter as true
			}
		}

		override public function endLevel(passed:Boolean, reason:String):void
		{
			//level's endLevel() function
			super.endLevel(passed, reason);
			
			//if player beat level
			if(passed)
			{
				_currScore += parseInt(timeRemainingText.text);
				scoreText.text = _currScore.toString();
			}
			else{
				if(_remainingLives != 0)
				{
					var tryAgainBtn:Button = new Button(Assets.ta.getTexture("tryAgainBtn"));
					tryAgainBtn.x = 250;
					tryAgainBtn.y = 250;
					addChild(tryAgainBtn);
					tryAgainBtn.addEventListener(TouchEvent.TOUCH, sameLevel);	
				}
			}
		}
		/**
		 * if user fails current level and clicks try again button
		 */
		private function sameLevel(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(this, TouchPhase.BEGAN);
			if (touch){
				JumpingGame.ref.levelUp(_currLevel, _remainingLives, _startScore);
			}
		}
		
		override public function update(timeDelta:Number):void
		{			
			//if game is not paused
			if(!paused){			
				//only want to add apples on a rare occassion
				canAddApple = Math.random();				
				if(canAddApple > 0.984 && apples.length == 0)
					addApples();
				
				for each(var a:Apple in apples)
				{
					if(a.x < hero.x - stage.stageWidth/2)
					{
						remove(a);
						apples.pop();
					}
				}
				
				//occassionally add a bird enemy
				canAddBird = Math.random();
				if(canAddBird > 0.9987)
					addBird();
				
				for each(var b:Bird in birds)
				{
					if(b.x < hero.x - stage.stageWidth)
					{
						remove(b);
						birds.pop();
					}
				}
				
				super.update(timeDelta);
				_hillsTexture.update();
			}
			else
				pigMC.stop();
			
			/**
			 * if user won the level
			 */
			/*else if(paused && applesEaten == 100)
			{
				if(hero.y <= cloudPlatform.y){
					hero.body.velocity.y = 0;
					hero.body.velocity.x = 0;
				}
			}*/
			
		}//end update function
	}
}