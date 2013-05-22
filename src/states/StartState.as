package states
{
	import citrus.core.starling.StarlingState;
	
	import flash.events.DataEvent;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.XMLSocket;
	import flash.utils.Timer;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class StartState extends StarlingState
	{	
		private var clouds:Array;	//array to hold clouds images
		
		private static const PORT:int = 5331;
		private static const LOCALHOST:String = "127.0.0.1";
		private var socket:XMLSocket;
		private var failed:Boolean = true;
		private var connectionError:String = "";
		private var connectionTextField:TextField;
		private var goTo:String = "";
		
		public function StartState()
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
			
			clouds = new Array();
			//fill array with cloud images
			for(var i:int = 0; i <= 7; i++){
				var c:Image = new Image(Assets.ta.getTexture("cloud"));
				//randomly position clouds
				c.x = Math.floor(Math.random() * (1 + 425 - (-100)) - 100);
				c.y = Math.random()*900 + stage.stageHeight;
				//randomly scale clouds
				c.scaleX = (Math.random() * (.7 - .4 + 1)) + .4;
				c.scaleY = c.scaleX;
				//add clouds to stage
				addChild(c);
				//add clouds to array
				clouds.push(c);
			}
			//everytime stage enters frame, call loop()
			addEventListener(Event.ENTER_FRAME, loop);
			
			/**
			 * add blue sky background to back of stage
			 * */
			var back:Image = new Image(Assets.backT);
			addChildAt(back, 0); 
			
			/**
			 * create, position and add title textual image to stage
			 * */
			var title:Image = new Image(Assets.ta.getTexture("whenPigsFly"));
			title.x = 80;
			title.y = 110;
			addChild(title);
			
			/**
			 * create, position and add play button to stage
			 * */
			var pb:Button = new Button(Assets.ta.getTexture("playBtn"));
			pb.name = "pb";
			pb.x = 250;
			pb.y = 350;
			addChild(pb);
			pb.addEventListener(Event.TRIGGERED, clickButton);
			
			/**
			 * create, position and add "how to" button to stage
			 * */
			var htb:Button = new Button(Assets.ta.getTexture("howToBtn"));
			htb.name = "htb";
			htb.x = 250;
			htb.y = pb.y + 75;
			addChild(htb);
			htb.addEventListener(Event.TRIGGERED, clickButton);
			
			/**
			 * create, position and add calibrate button to stage
			 * */
			var cb:Button = new Button(Assets.ta.getTexture("calibrateBtn"));
			cb.name = "cb";
			cb.x = 250;
			cb.y = htb.y + 75;
			addChild(cb);
			cb.addEventListener(Event.TRIGGERED, clickButton);	
			
			
			connectionTextField = new TextField(stage.stageWidth, 55, "", "Arial", 14, 0x0d0d0d, false);
			connectionTextField.x = 0;
			connectionTextField.y = title.y + title.height + 15;
			connectionTextField.hAlign = HAlign.CENTER;
			connectionTextField.vAlign = VAlign.TOP;
						
		}
				
		private function loop(e:Event):void
		{
			for each(var c:Image in clouds)
			{				
				c.y -= .75;	//move each cloud up .75 pixels
				
				//if y position of current cloud is less than negative of its height 
				//basically if it's above the stage, we're going to reposition it at the bottom of the stage with new size and position
				if(c.y <= -c.height){
					c.y = Math.random()*900 + stage.stageHeight;
					c.x = Math.floor(Math.random() * (1 + 425 - (-100)) - 100);
					c.scaleX = (Math.random() * (.9 - .4 + 1)) + .4;
					c.scaleY = c.scaleX;
				}
			}
		}
		
		/**
		 * called every time the user tries to switch screens
		 * if the serproxy is not running
		 * or sensor is not plugged in
		 * errors will be thrown and the user will be prompted
		 * */
		private function newSocket():void
		{			
			failed = true;
			
			connectionError= "";
			removeChild(connectionTextField);
			
			socket = new XMLSocket();
			socket.connect(LOCALHOST, PORT);
			socket.addEventListener(flash.events.Event.CONNECT, socketConnected);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}
		
		private function switchState(state:String):void
		{
			if(!failed){
				switch(state){
					case "pb":
					JumpingGame.ref.switchState("GAMEPLAY");
					break;
					case "htb":
					JumpingGame.ref.switchState("RULES");
					break;
					case "cb":
					JumpingGame.ref.switchState("CALIBRATE");
					break;
				}
			}
			
		}
		
		//if serproxy is running
		private function socketConnected(e:flash.events.Event):void
		{	
			socket.addEventListener(DataEvent.DATA, dataReceiver);
		}
		
		//if receiving data from sensor, meaning it's plugged in
		private function dataReceiver(event:DataEvent):void
		{
			failed = false;
			socket.removeEventListener(DataEvent.DATA, dataReceiver);
			socket.close();
			switchState(goTo);
		}
		
		//if serproxy is not running, dispatch error instead of crashing
		private function onIOError(e:IOErrorEvent):void 
		{
			this.dispatchEvent(new starling.events.Event("SOCKET_ERROR"));
			trace("failed");
			connectionError += "Failed to connect. Make sure the serproxy.exe is running and\npressure sensor is plugged into the USB port.";
			connectionTextField.text = connectionError;				
			addChild(connectionTextField);
		}
		
		private function clickButton(e:Event):void
		{
			goTo = (e.currentTarget as Button).name;
			newSocket();
		}
		
	}
}