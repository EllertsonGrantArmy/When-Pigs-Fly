package
{	
	import citrus.core.starling.StarlingCitrusEngine;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import levels.LevelOne;
	import levels.LevelTwo;
	
	import states.*;
	
	[SWF(width="500", height="625", frameRate="60", backgroundColor="0x42cdf4")]
	
	/**
	 * This is the main class of the project. 
	 * 
	 * @author Kayla Johnson
	 * 
	 */
	public class JumpingGame extends StarlingCitrusEngine
	{
		public static var ref:JumpingGame;
		
		//intial values when game launched
		private const LEVEL:int = 1;
		private const LIVES:int = 5;
		private const SCORE:int = 0;
		
		private var levelData:XML; //level time, platform count, etc for each level
		
		public function JumpingGame()
		{
			JumpingGame.ref = this; //reference for other classes to this class
			
			setUpStarling(); //set up starling for game
			
			var myLoader:URLLoader = new URLLoader(); //loader for xml
			myLoader.load(new URLRequest("assets/levelData.xml")); //load level data
			myLoader.addEventListener(Event.COMPLETE, loadXML); //when done loading level data xml
			myLoader.addEventListener(IOErrorEvent.IO_ERROR, handleLoadErrorEvent); //if there was an error loading xml
						
			//starting state for application is StartState()
			state = new StartState();
		}
		
		protected function handleLoadErrorEvent(e:IOErrorEvent):void
		{
			throw new IOError("XML LEVEL DATA LOAD ERROR.");
		}
		
		protected function loadXML(e:Event):void
		{
			levelData = new XML(e.target.data);
			var levelList:XMLList = levelData.LEVEL;
		}
		
		public function switchState(s:String):void
		{
			switch (s){
				case "HOME":
					state.destroy();
					state = new StartState();
					break;
				case "GAMEPLAY":
					levelUp(LEVEL, LIVES, SCORE);	
					break;
				case "RULES":
					state.destroy();
					state = new RulesState();
					break;
				case "CALIBRATE":
					state.destroy();
					state = new CalibrateState();
					break;
				default:
					trace("Switching state error");
			}
		}
		
		//called from above to go to level one or level two
		public function levelUp(goToLevel:int, remainingLives:int, myScore:int):void
		{				
			var time:int = parseInt(levelData.LEVEL[goToLevel-1].TIME);
			
			if(goToLevel == 1){
				var pCount:int = parseInt(levelData.LEVEL[goToLevel-1].PLATFORMS);
				var pSpeed:int = parseInt(levelData.LEVEL[goToLevel-1].SPEED);
				
				
				//state = new LevelTwo(goToLevel, remainingLives, myScore, time);
				state = new LevelOne(goToLevel, remainingLives, pCount, myScore, time);
			}
			else if(goToLevel == 2){
				state.destroy();
				state = new LevelTwo(goToLevel, remainingLives, myScore, time);
			}
		}		
		
	}
}