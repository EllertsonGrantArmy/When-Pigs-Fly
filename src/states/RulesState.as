package states
{
	import citrus.core.starling.StarlingState;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.VAlign;
	
	public class RulesState extends StarlingState
	{
		private var page:int = 1;	//starting page being viewed
		private var backBtn:Button;	//back button to go to previous page
		private var nextBtn:Button;	//next button to go to next page
		private var title:TextField; //textfield to hold title of current page
		private var explanationString:TextField; //textfield holding main explanation of each page
		private var explanationTwo:TextField; //second textfield showing secondary explanation on each page
		private var cloudTwo:Image;			//second cloud for secondary information
		private var header:Image;		//green header bar at the top of the page
		private var playBtn:Button;		//play button at the bottom of the last page
		private var bird:Image;			//bird image
		private var flyingPig:Image;	//flying pig image for level one
		private var arrow:Image;		//arrow pointing to header
		private var livesHead:Image;	//icon representing number of lives remaining
		private var resumeText:TextField; //resume button
		private var instructions:XML;		//xml file we'll use to pull text to fill explanation textfields
		private var appleCoin:Image;		//small apple image showing collectable apple
		private var appleText:TextField;	//text representing how many apples have been collected
		private var levelTwoPig:Image;		//flying pig for level two
		
		public function RulesState()
		{
			//call super (StarlingState)'s constructor
			super();
		}
		
		override public function initialize():void
		{
			//call super (StarlingState)'s initialize() function
			super.initialize();
			
			//initialize assets to use images
			Assets.init();
			
			/**
			 * to load external xml which holds text for explanation textfields
			 * */
			var myLoader:URLLoader = new URLLoader();
			myLoader.load(new URLRequest("assets/instructions.xml")); //load xml
			myLoader.addEventListener(flash.events.Event.COMPLETE, loadXML); //when done loading, call loadXML() function
			myLoader.addEventListener(IOErrorEvent.IO_ERROR, handleLoadErrorEvent); //if there was an error loading, handle error
			
			var back:Image = new Image(Assets.backT);
			addChildAt(back, 0);
			//add blue sky background at 0 z-index on stage
			
			/**
			 * position and add back button which brings the user to the previous page when clicked 
			 * */
			backBtn = new Button(Assets.ta.getTexture("backBtn"));
			backBtn.x = 30;
			backBtn.y = 555;
			addChild(backBtn);
			backBtn.addEventListener(TouchEvent.TOUCH, previousPage);
			
			/**
			 * position and add next button which brings the user to the next page when clicked 
			 * */
			nextBtn = new Button(Assets.ta.getTexture("nextBtn"));
			nextBtn.x = stage.stageWidth - 30 - nextBtn.width;
			nextBtn.y = backBtn.y;
			addChild(nextBtn);
			nextBtn.addEventListener(TouchEvent.TOUCH, nextPage);
			
			/**
			 * position and add "How To" textual image
			 * */
			var howToImage:Image = new Image(Assets.ta.getTexture("howToPlay"));
			howToImage.x = 50;
			howToImage.y = 55;
			addChild(howToImage);
			
			/**
			 * position and add cloud, on top of which explanation text will be shown 
			 * */
			var cloud:Image = new Image(Assets.ta.getTexture("cloud"));
			cloud.x = 80;
			cloud.y = 90;
			cloud.scaleX = 1.4;
			cloud.scaleY = cloud.scaleX;
			addChild(cloud);
			
			/**
			 * position and add second cloud for secondary explanation to be placed on top of
			 * */
			cloudTwo = new Image(Assets.ta.getTexture("cloud"));
			cloudTwo.x = 25;
			cloudTwo.y = cloud.y + cloud.height + 60;
			addChild(cloudTwo);
			
			/**
			 * position and add title of each page at the top of the first cloud
			 * */
			title = new TextField(170, 75, "", "Arial", 24, 0x141414, false);
			title.x = cloud.x + cloud.width/2 - title.width/3 - 2;
			title.y = cloud.y + 35;
			title.vAlign = VAlign.TOP;	//vertical align of text is set to top of textfield
			addChild(title);
			
			/**
			 * explanationString is explanation placed above cloud one and contains primary information pulled from the xml file
			 * */
			explanationString = new TextField(cloud.width - 30, cloud.height, "", "Arial", 13, 0x141414, false);			
			explanationString.x = cloud.x + 13;
			explanationString.y = cloud.y + cloud.height/2;
			explanationString.vAlign = VAlign.TOP;
			addChild(explanationString);
				
			/**
			 * explanationTwo is explanation placed above cloud two and contains secondary information pulled from the xml file
			 * */
			explanationTwo = new TextField(cloudTwo.width, 100, "", "Arial", 13, 0x141414, false);
			explanationTwo.x = cloudTwo.x;
			explanationTwo.y = cloudTwo.y + 80;
			explanationTwo.vAlign = VAlign.TOP;
			addChild(explanationTwo);
			
			
			//PAGE ONE SPECIFIC CONTENT			
			
			flyingPig = new Image(Assets.ta.getTexture("pigWingsUp"));
			flyingPig.x = cloud.x + cloud.width/2.5; //position around first cloud
			flyingPig.y = cloud.y - 40;
			flyingPig.scaleX = .75; //scale pig
			flyingPig.scaleY = flyingPig.scaleX;
			
			bird = new Image(Assets.ta.getTexture("bird1"));
			bird.x = 25 + bird.width;	//position near cloud two
			bird.y = cloudTwo.y - bird.height;
			bird.scaleX = 0.9;	//scale bird to be slightly smaler
			bird.scaleY = bird.scaleX;
			
					
			
			
			//PAGE TWO SPECIFIC CONTENT
			appleCoin = new Image(Assets.ta.getTexture("appleCoin"));
			appleCoin.x = explanationTwo.x + 150; //position apple
			appleCoin.y = cloudTwo.y- appleCoin.height/2;
			
			levelTwoPig = new Image(Assets.ta.getTexture("pigWithWingsUp"));
			levelTwoPig.x = flyingPig.x;	//position level two pig in same spot as flying pig was
			levelTwoPig.y = flyingPig.y;
			levelTwoPig.scaleX = .75; //scale pig to be slightly smaller
			levelTwoPig.scaleY = levelTwoPig.scaleX;
			
			
			
			//PAGE THREE SPECIFIC CONTENT
			header = new Image(Assets.ta.getTexture("howToHeader"));
			header.x = 0;
			header.y = 0;			
			
			arrow = new Image(Assets.ta.getTexture("howToArrow"));
			arrow.x = stage.stageWidth - arrow.width - 15;
			arrow.y = howToImage.y + 5;
			arrow.rotation = 25;
			
			
			livesHead = new Image(Assets.ta.getTexture("livesHead"));
			livesHead.x = cloudTwo.x + 155;
			livesHead.y = cloudTwo.y + 15;
		}
		
		protected function handleLoadErrorEvent(e:IOErrorEvent):void
		{
			throw new IOError("XML LOAD ERROR.");
		}
		
		protected function loadXML(e:flash.events.Event):void
		{
			instructions = new XML(e.target.data);
			
			//put all page one content on screen
			loadPageOne();
		}
		
		private function nextPage(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(this, TouchPhase.BEGAN);
			if (touch && page <= 4){
				
				page++; //increment page
				
				//GO TO PAGE TWO
				if(page == 2)
					loadPageTwo();
				
				//GO TO PAGE THREE
				else if(page == 3)
					loadPageThree();
				
				//GO TO PAGE FOUR
				else if(page == 4)
					loadPageFour();
			}
		}
		
		private function previousPage(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(this, TouchPhase.BEGAN);
			if (touch){
				
				page--; //decrement page
				
				if(page == 0)
					JumpingGame.ref.switchState("HOME");
					
				else if(page == 1)
					loadPageOne();
					
				else if(page == 2)
					loadPageTwo();
				
				else if(page == 3)
					loadPageThree();
			}
			
		}
		
		private function loadPageOne():void
		{
			//if coming from page 2, delete content from it
			if(levelTwoPig){
				removeChild(levelTwoPig);
				removeChild(appleCoin);
				
			}
			
			//add page one content to stage
			addChild(bird);
			addChild(flyingPig);
			
			//update title on page to match what's in xml
			title.text = instructions.PAGE[page-1].TITLE.toString();
			//update explanation to content of xml file
			explanationString.text = instructions.PAGE[page-1].EXPLANATION.toString();
			//update second explanation to content of xml file
			explanationTwo.text = instructions.PAGE[page-1].SECONDEXP.toString();
		}
		
		private function loadPageTwo():void
		{
			//if coming from page 1, delete content from it
			if(flyingPig){
				removeChild(flyingPig);
				removeChild(bird);
			}
			//if coming from page 3, delete content from it
			if(header){
				removeChild(arrow);
				removeChild(header);
				removeChild(livesHead);
				removeChild(resumeText);
				removeChild(appleText);
			}
			
			//reposition apple
			appleCoin.x = explanationTwo.x + 150;
			appleCoin.y = cloudTwo.y - appleCoin.height/2;	
			
			//add level 2 page items
			addChild(appleCoin);
			addChild(levelTwoPig);
			
			//update title on page to match what's in xml
			title.text = instructions.PAGE[page-1].TITLE.toString();
			//update explanation to content of xml file
			explanationString.text = instructions.PAGE[page-1].EXPLANATION.toString();
			//update second explanation to content of xml file
			explanationTwo.text = instructions.PAGE[page-1].SECONDEXP.toString();			
		}
		
		private function loadPageThree():void
		{		
			//if coming from page 4, delete content from it
			if(playBtn){
				addChild(nextBtn);
				removeChild(playBtn);
				addChild(cloudTwo);
				addChild(explanationTwo);
				removeChild(appleCoin);
			}
			
			//if coming from page 2, delete content from it
			else if(levelTwoPig){
				removeChild(levelTwoPig);
			}
			
			//add level 3 items
			addChild(arrow);
			addChild(header);
			addChild(livesHead);
			
			//reposition apple and add it
			appleCoin.x = 105;
			appleCoin.y = 3;
			addChild(appleCoin);
			
			//textfield representing apples collected
			appleText = new TextField(35, 25, "42", "Salam", 16, 0xffffff, false);
			appleText.x = appleCoin.x + 15;
			appleText.y = 3;
			addChild(appleText);

			
			//update title on page to match what's in xml
			title.text = instructions.PAGE[page-1].TITLE.toString();
			//update explanation to content of xml file
			explanationString.text = instructions.PAGE[page-1].EXPLANATION.toString();
			//update second explanation to content of xml file
			explanationTwo.text = instructions.PAGE[page-1].SECONDEXP.toString();
		}
		
		private function loadPageFour():void
		{		
			//delete content from page 3 and next button
			removeChild(nextBtn);
			removeChild(header);
			removeChild(arrow);
			removeChild(livesHead);
			removeChild(resumeText);
			removeChild(appleText);
			removeChild(appleCoin);
			removeChild(explanationTwo);
			removeChild(cloudTwo);
			
			//play button to go to level one when clicked
			playBtn = new Button(Assets.ta.getTexture("playBtn"));
			playBtn.x = stage.stageWidth - 30 - playBtn.width;
			playBtn.y = backBtn.y;
			addChild(playBtn);
			playBtn.addEventListener(starling.events.Event.TRIGGERED, clickPlay);
			
			//update title on page to match what's in xml
			title.text = instructions.PAGE[page-1].TITLE.toString();
			//update explanation to content of xml file
			explanationString.text = instructions.PAGE[page-1].EXPLANATION.toString();
		}
		
		private function clickPlay(e:starling.events.Event):void
		{
			//go to level one
			JumpingGame.ref.switchState("GAMEPLAY");
		}
	}
}