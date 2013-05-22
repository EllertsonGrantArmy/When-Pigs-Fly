package states
{
	import citrus.core.starling.StarlingState;
	
	import flash.events.DataEvent;
	import flash.events.TimerEvent;
	import flash.net.XMLSocket;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class CalibrateState extends StarlingState
	{		
		private var socket:XMLSocket;	//socket to connect to sensor
		private var PORT:int = 5331;	//port number to connect to sensor
		private var LOCALHOST:String = "127.0.0.1";	//host for connecting to sensor
		
		private var ability:Array;	//to hold numbers from sensor when squeezed
		private var _calibration:int = 0;	//final number calculated from array
		
		private var timerText:TextField;	//timer text to show 3..2..1..
		private var timer:Timer;			//timer to count 3 seconds
		private var complete:Boolean = false;	//if sensor held for 3 consecutive
		
		public static var ref:CalibrateState;	//reference to this state from other states
		
		public function CalibrateState()
		{
			//call super (StarlingState)'s constructor
			super();
			//create reference to this class for other classes
			CalibrateState.ref = this;
		}
		
		override public function initialize():void
		{
			//call super (StarlingState)'s initialize() function
			super.initialize();
			
			Assets.init();		//call Asset's initialize to use images	
			
			timer = new Timer(1000, 3);	//timer to run for 1000 miliseconds 3 times
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, getAverage); //when complete, call getAverage() function
			timer.addEventListener(TimerEvent.TIMER, updateText);	//when gone through 1000 miliseconds, call updateText() function
			
			openSocket();	//open socket function
			
			var back:Image = new Image(Assets.backT);
			addChildAt(back, 0);
			//add blue sky background to stage
			
			/**
			 * home button to go back to home screen
			 * */
			var homeBtn:Image = new Image(Assets.ta.getTexture("homeBtn"));
			homeBtn.x = 30;
			homeBtn.y = 555;
			addChild(homeBtn);
			homeBtn.addEventListener(TouchEvent.TOUCH, clickBack);
			
			/**
			 * textfield to show user instructions to calibrate device
			 * */
			var instructions:TextField = new TextField(stage.stageWidth, 150, "", "arial", 26, 0xffffff, false);
			instructions.x = 0;
			instructions.y = stage.stageHeight/2 - 70;
			instructions.hAlign = HAlign.CENTER;
			instructions.vAlign = VAlign.TOP;
			instructions.text = "Squeeze the sensor as hard as you can to calibrate the device to your personal ability.\n"
				+ "Hold your squeeze for 3 seconds. If you let go before time is up, the timer will restart.";
			addChild(instructions);
			
			/**
			 * timer text to show 3..2..1...
			 * */
			timerText = new TextField(stage.stageWidth, 150, "", "arial", 30, 0xffffff, false);
			timerText.x = 0;
			timerText.y = instructions.y + 160;
			timerText.hAlign = HAlign.CENTER; //center align text
			timerText.vAlign = VAlign.TOP;	//top align text
			addChild(timerText);	//add to stage
		}
		
		private function clickBack(e:TouchEvent):void
		{
			//if clicked back button, go to home screen
			var touch:Touch = e.getTouch(this, TouchPhase.BEGAN);
			if (touch){
				//close socket
				if(socket.connected)
					socket.close();
				goHome();		
			}	
		}
		
		private function goHome():void
		{
			JumpingGame.ref.switchState("HOME");
		}
		
		//connect to sensor and open socket
		private function openSocket():void
		{
			socket = new XMLSocket();
			socket.addEventListener(DataEvent.DATA, onDataRecieved);
			socket.connect(LOCALHOST, PORT);			
		}
		
		public function onDataRecieved(event:DataEvent):void
		{
			//data is amount of pressure received from sensor
			if(event.data.substr(0,2) == "A0")
			{
				var data:int = parseInt(event.data.substr(2,6));
			
				trace(data);
				//start timer if squeezing
				if(data > 0 && !timer.running && !complete)
				{
					ability = new Array();
					timer.start();
				}
				//if user lets go too early, reset the timer
				else if(data <= 0 && timer.running)
					timer.reset();
				
				//if timer is running, add values to array
				else if(data > 0 && timer.running)
					ability.push(data);
			}
		}
		
		protected function updateText(event:TimerEvent):void
		{
			//update timer textfield with current count from timer
			timerText.text += timer.currentCount.toString() + ".. ";
		}
		
		//calculates average ability from those 3 seconds
		protected function getAverage(event:TimerEvent):void
		{
			complete = true; //squeeze complete
			
			//close socket
			if(socket.connected)
				socket.close();
			
			for(var i:int = 0; i < ability.length;i++)
				_calibration += ability[i];
			
			//get average
			_calibration = _calibration/ability.length;
			
			//add "calibrated!!" to timer textfield
			timerText.text += "\nCalibrated!!";
			
			//go to home screen after 1 second
			setTimeout(goHome, 1000);
		}

		public function get calibration():int
		{
			return _calibration;
		}

	}
}