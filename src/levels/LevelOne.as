package levels
{
	import citrus.core.CitrusGroup;
	import citrus.math.MathVector;
	import citrus.objects.CitrusSprite;
	import citrus.objects.common.Path;
	import citrus.objects.platformer.nape.Coin;
	import citrus.objects.platformer.nape.Platform;
	
	import flash.events.DataEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.utils.setTimeout;
	
	import nape.callbacks.CbType;
	import nape.geom.Vec2;
	import nape.phys.BodyType;
	
	import objects.Bird;
	import objects.Feather;
	import objects.FollowTargetComponent;
	import objects.JumpingHero;
	import objects.MyPlatform;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.core.starling_internal;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.particles.PDParticleSystem;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.Color;
	import starling.utils.HAlign;
	import starling.utils.deg2rad;
	
	import states.CalibrateState;
	
	public class LevelOne extends Level 
	{		
		public static var ref:LevelOne;		//reference to this class from others
		
		public var hero:JumpingHero;		//pig hero
		
		private var platforms:Array;		//to hold all platform objects
		private var birds:Array;			//to hold all bird objects
		private var particles:Array; 		//to hold any particles put on stage
		
		private var _currLevel:int;			//current level of game
		private var _platformCount:int;		//number of platforms (clouds) to add
		private var _platformSpeed:int;		//average speed of platforms
		private var _currScore:int;			//current score from previous tries (if lost lives, score remains)
		
		private var feedbackTF:TextField;	//on screen feedback for user, like "bird hit" or "feather caught"

		private const PLATFORM_Y:int = 420;		//height between platforms
		
		private var hitBirdParticles:PDParticleSystem; //blue particles when bird hit
		private var feather:Feather;	//feather created when bird hit
		private var catchFeatherParticles:PDParticleSystem; //blue line of particles when feather caught
		
		private var pigGroup:CitrusGroup; //group to move pig and his feathers together
		private var pigFeathers:Array;	//feathers held by pig
		private var len:int;	//length of pigfeathers array	
		
		private const MAX_HEIGHT:int = -25000; //max height of stage that pig can jump
		private const BIRD_COUNT:int = 20;	//birds to add to the stage (initially)
		private const CLOUD_SPACING:int = 275;
		
		private var _calibration:int; //calibration from calibration state if done
		
		
		public function LevelOne(currLevel:int, remainingLives:int, platformCount:int, currScore:int, countSeconds:int)
		{
			super();
			
			LevelOne.ref = this; //reference for other classes to this class
			
			_currLevel = 		currLevel;
			_remainingLives = 	remainingLives;
			_platformCount = 	platformCount;
			_currScore =	 	currScore;
			_countSeconds = 	countSeconds;
			
			//if the user has gone to and compeleted the calibration state 
			if(CalibrateState.ref)
				_calibration =		CalibrateState.ref.calibration;
			//if not, calibration ability set to 0
			else _calibration = 	0;
			
		}
		
		override public function initialize():void
		{
			super.initialize();
			
			//grassy striped ground platform
			var ground:Platform = new Platform("floor", {x:stage.stageWidth/2, y:25, width:stage.stageWidth, offsetY:-25});
			ground.view = new Image(Assets.groundT);
			add(ground);
			
			//array to hold platforms
			platforms = new Array();
			
			//array to hold all birds
			birds = new Array();
			
			//array to hold any onscreen particles
			particles = new Array();
			
			//array to hold all the feathers the bird can obtain
			pigFeathers = new Array();
			
			//create pig group for pig and feathers
			pigGroup = new CitrusGroup("pigGroup");
			//add pig group to stage
			addEntity(pigGroup);
			
			//initial instructions on screen
			instructions.text = "Hit birds to steal their feathers.\nCollect 6 feathers to win.";
			
			//update scoreText field to current score (0 if first time)
			scoreText.text =_currScore.toString();
			//update lives textfield to remaining lives
			livesText.text += _remainingLives;
			
			//create feedback textfield
			feedbackTF = new TextField(stage.stageWidth/2, 35, "", "Arial", 25, 0xffffff, false);
			feedbackTF.x = stage.stageWidth/4;
			feedbackTF.y = stage.stageHeight/2;
			feedbackTF.alpha = 0.6;	//slightly transparent
			feedbackTF.hAlign = HAlign.CENTER; //horizontal align text in textfield
						
			//jumping pig "hero"
			hero = new JumpingHero("pig", {x:stage.stageWidth/2 , y: 0, width:65, height:85, offsetY:4});
			hero.view = new MovieClip(Assets.ta.getTextures("pigTail"), 5);	
			
			//create and add cloud platforms to stage
			addClouds();
			
			//creates and adds birds
			addBirds();
			
			//creates feathers to be added to pig group
			createFeathers();					
			
			//add hero to stage after clouds so he's above them visually
			add(hero);	
			//add pig to group as follow target so feathers will move with him
			pigGroup.add(new FollowTargetComponent("followTarget", {follow:hero}));
			
			//keep the view focused on the pig 
			view.camera.setUp(hero, new citrus.math.MathVector(stage.stageWidth/2, (stage.stageHeight / 2) + 150),
				new Rectangle(0, MAX_HEIGHT, stage.stageWidth, int.MAX_VALUE), new MathVector(.05, .25));			
		}
		
		private function addClouds():void
		{
			//adding _platformCount amount of platforms to stage
			for(var i:int = 0; i <= _platformCount; i++){				
				//create moving cloud platform
				var p:MyPlatform = new MyPlatform("mp"+[i], {width: 145, height:2, speed: 25}); 
				add(p);								//add platform to stage
				if(hero.y < MAX_HEIGHT/2)
					p.y = (-i - _platformCount) * (PLATFORM_Y*2) - CLOUD_SPACING;
				else 
					p.y = -i*PLATFORM_Y - CLOUD_SPACING;
				p.x = Math.floor(Math.random() * (1 + 425 - 75) + 75);	//random x on the screen
				p.view = new Image(Assets.ta.getTexture("cloud"));	//add image to platform
				p.view.scaleX = 0.7;
				p.view.scaleY = 0.4;
				p.oneWay = true;				//allow the user to come up through the bottom of the platform
				p.path = new Path("lr" + [i]);	//add a path for the platform to follow
				p.path.add(75, p.y);		//goes to the left until 75, staying at current y
				p.path.add(425, p.y);		//goes to the right until 425, staying at current y
				p.path.isPolygon = false;	//platform doesn't follow polygon shaped path, follows a horizontal line
				platforms.push(p);			//add platform to array
			}
		}
		
		/**
		 * create 20 birds
		 * */
		private function addBirds():void
		{
			//create and animate 20 (BIRD_COUNT) number of birds
			for(var f:int = 0; f < BIRD_COUNT; f++)
			{
				//either place the bird on the left or right side of the stage
				var birdX:int = (Math.floor((Math.random() * 10) % 2) == 0) ? 25 : stage.stageWidth;
				
				var birdY:int
				//add more birds if the user goes too high and out of reach of first 20 birds
				if(hero.y < MAX_HEIGHT/2)//p.y = (-i - _platformCount) * (PLATFORM_Y*2) - 275;
					birdY = (-f - BIRD_COUNT) * (PLATFORM_Y*2) - 325;
				else
					birdY = -f * (PLATFORM_Y*2) - 325;
				
				//create a bird "enemy" object
				var bird:Bird = new Bird("bird", {x: 25, y: birdY, radius: 25, speed: 45});
				bird.view = new MovieClip(Assets.ta.getTextures("bird"), 2);	//set the view for the bird to be the aqua bird
				add(bird);			//add the current bird to the stage
				
				bird.body.allowRotation = false;	//bird can't rotate (when hit by pig or coud)
				bird.body.kinematicVel = new Vec2(1, 1); //keeps bird afloat
				bird.body.type = BodyType.KINEMATIC;	//prevent collision with clouds
				bird.leftBound = 0;
				bird.rightBound = stage.stageWidth;
				
				birds.push(bird);	//add the current bird to the array
			}
		}
		
		/**
		 * create 6 feathers that will later be added to the pig
		 * */
		private function createFeathers():void
		{
			
			for(var k:int = 0; k < 6; k++)
			{
				var featherImage:CitrusSprite = new CitrusSprite("pigFeather");
				featherImage.view = new Image(Assets.ta.getTexture("feather"));
				featherImage.view.scaleX = featherImage.view.scaleY = 0.7;	
				pigFeathers.push(featherImage);
			}
		}
		
		//called from Bird when pig hits bird
		public function hitBird(bird:Bird):void
		{
			//tween x and y of bird
			var tween:Tween = new Tween(bird, 2.5);
			tween.animate("x", stage.stageWidth/2); 
			tween.animate("y", hero.y - 75);
			tween.delay = .1;
			Starling.juggler.add(tween);	//add tween to juggler to see it animate
			tween.onComplete = addFeather;	//when done tweening, call addFeather() function
			tween.onCompleteArgs = new Array(bird);	//and pass it the current bird
			
			birds.pop(); //remove bird from array
			
			Assets.birdTweet.play(0);
			
			//add new particle to stage
			hitBirdParticles = new PDParticleSystem(XML(new Assets.starParticle()),
				Assets.ta.getTexture("texture"));
			Starling.juggler.add(hitBirdParticles);
			hitBirdParticles.start();
			hitBirdParticles.x = stage.stageWidth/2;
			hitBirdParticles.y = stage.stageHeight/2;
			addChild(hitBirdParticles);
			particles.push(hitBirdParticles);
			
			feedbackTF.text = "bird hit!";
			addChild(feedbackTF);
			
			//after 1000 miliseconds, call stopParticles()
			setTimeout(stopParticles, 1000);
		}
	
		
		/**
		 * Called when hero hits bird
		 * creates new feather that will fall somewhat gracefully
		 **/
		public function addFeather(bird:Bird):void
		{
			feather = new Feather("feather", {x: stage.stageWidth/2, y: bird.y, width: 70, height: 17, rotation: deg2rad(15)});
			feather.view = new Image(Assets.ta.getTexture("feather"));
			add(feather);	
			feather.body.velocity.y = 0.0001; //slight y velocity moves it down
			feather.body.gravMass = 0.01;	//light graviational mass to be feather-like
			feather.rotation = deg2rad(15); //rotate feather
			bird.kill = true;				//remove bird from stage	
		}
		
		/**
		 * Called when user catches feather
		 * adds smaller feather to set of wings
		 **/
		public function catchFeather():void
		{
			//increment total score +20
			_currScore += 20;
			//update score textfield
			scoreText.text = _currScore.toString();
			
			//add particles to stage
			catchFeatherParticles = new PDParticleSystem(XML(new Assets.coolParticle()),
				Assets.ta.getTexture("texture"));
			Starling.juggler.add(catchFeatherParticles); //add to juggler to see animation
			catchFeatherParticles.start();	//start particles
			catchFeatherParticles.x = stage.stageWidth/2;
			catchFeatherParticles.y = stage.stageHeight/2;
			addChild(catchFeatherParticles);	
			particles.push(catchFeatherParticles);		
			
			Assets.wingFlap.play();
			
			len = pigFeathers.length;			
						
			if(len % 2 != 0)
				pigFeathers[len-1].view.scaleX = -0.7;
			//rotate every other feather to be flipped horizontally
			
			//rotate feather slightly
			pigFeathers[len-1].rotation = deg2rad(29);
			//add feather to stage
			add(pigFeathers[len-1]);
			//add feather to pig group
			pigGroup.addObject(pigFeathers[len-1]);
			pigGroup.initialize();
						
			
			feedbackTF.text = "feather caught!";
			addChild(feedbackTF);
			
			/**remove feather from feathers array
			*when the length of that array is 0, meaning the hero has caught all 6,
			*end the level with the "passed" parameter as true
			 * */
			pigFeathers.pop();
			if(len-1 == 0)
				endLevel(true, "passed");
			
			//stop particles after 1000 miliseconds
			setTimeout(stopParticles, 1000);
		}
		
		protected function stopParticles():void
		{
			//remove "bird hit" or "feather caught"
			removeChild(feedbackTF);
			
			for(var i:int = 0; i < particles.length; i++)
			{
				(particles[i] as PDParticleSystem).stop();
				removeChild(particles[i]);
				Starling.juggler.remove(particles[i]);
			}
			
			/*if(hitBirdParticles)
			{
				hitBirdParticles.stop(); //stop particles from animating
				removeChild(hitBirdParticles); //remove them from stage
				Starling.juggler.remove(hitBirdParticles);	//remove them from juggler				
			}
			
			if(catchFeatherParticles)
			{		
				catchFeatherParticles.stop(); //stop particles from animating
				removeChild(catchFeatherParticles); //remove them from stage
				Starling.juggler.remove(catchFeatherParticles);	//remove them from juggler	
			}*/
		}
		
		/*override public function startGame():void
		{
			super.startGame();			
			
			Assets.levelOneBgm.play();
		}
		
		override public function pauseResumeGame(e:TouchEvent):void
		{
			super.pauseResumeGame(e);
			
			if(super.paused)
				Assets.myChannel = Assets.levelOneBgm.play();
			else
				Assets.myChannel.stop();
		}*/
		
		public function get Platforms():Array
		{
			return platforms;
		}
		
		override public function endLevel(passed:Boolean, reason:String):void
		{
			//level's endLevel() function
			super.endLevel(passed, reason);
			
			//if player beat level
			if(passed)
			{
				//create and add next level button
				var nextLevelBtn:Button = new Button(Assets.ta.getTexture("nextLevelBtn"));
				nextLevelBtn.x = stage.stageWidth/2;
				nextLevelBtn.y = 250;
				addChild(nextLevelBtn);
				nextLevelBtn.addEventListener(TouchEvent.TOUCH, nextLevel);
				
				_currScore += parseInt(timeRemainingText.text);
				scoreText.text = _currScore.toString();
				
			}
			
			//if player lost level
			else
			{
				if(_remainingLives != 0)
				{
					var tryAgainBtn:Button = new Button(Assets.ta.getTexture("tryAgainBtn"));
					tryAgainBtn.x = 250;
					tryAgainBtn.y = 250;
					addChild(tryAgainBtn);
					tryAgainBtn.addEventListener(TouchEvent.TOUCH, sameLevel);	
				}
			}
			
			//removes cloud platforms from screen
			for(var i:int = 0; i < platforms.length; i++){
				remove(platforms[i]);	//removes platform from stage
			}
		}
		
		/**
		 * when receiving data from arduino
		 */
		override public function onDataReceived(event:DataEvent):void
		{
			var data:int = parseInt(event.data);
			
			if(event.data.substr(0,2) == "A0"){
				data = parseInt(event.data.substr(2,6));
			}
			data = data * 6.25;
			
			if(hero.onGround && data > 10)
				if(_calibration == 0 || (_calibration > 75 && _calibration < 125) ) //if no calibration done or average
					hero._updateAnimation(true, data);
				else if (_calibration >= 0 && _calibration <= 75) //if user is weak
					hero._updateAnimation(true, data*1.5);
				else if (_calibration >= 125 && _calibration <= 500) //if user is strong
					hero._updateAnimation(true, data*0.75);
		}
		
		
		/**
		 * if user presses next level button
		 */
		private function nextLevel(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(this, TouchPhase.BEGAN);
			if (touch){
				_currLevel++; //increment current level
				JumpingGame.ref.levelUp(_currLevel, _remainingLives, _currScore); //go to next level
			}
		}
		
		/**
		 * if user fails current level and clicks try again button
		 */
		private function sameLevel(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(this, TouchPhase.BEGAN);
			if (touch){
				JumpingGame.ref.levelUp(_currLevel, _remainingLives, 0);
			}
		}
		
		
		override public function update(timeDelta:Number):void 
		{
			super.update(timeDelta);
			
			//if the game is active
			if(!paused){
				//in case pig goes too far to the left or right when falling, keep them on screen
				if(hero.x < 0)
					hero.x = 0;
				if(hero.y > stage.stageWidth)
					hero.x = stage.stageWidth;
				
				//if pig goes halfway up the stage and still hasn't caught 6 feathers, add more birds to hit
				if(hero.y < MAX_HEIGHT/2){
					addBirds();			
					addClouds()
				}
				
				//if hero falls more than 6 platforms, fallen too much and end level
				if(JumpingHero.ref.currentY - hero.y < -(CLOUD_SPACING * 6))
					endLevel(false, "height");
				
			} //end if not paused
			
		} //end update
	}
}