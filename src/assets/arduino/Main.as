package  {
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.net.XMLSocket;
	import flash.events.IEventDispatcher;
	import flash.events.DataEvent;
	
	public class Main extends MovieClip {
		
		private var socket:XMLSocket;
		private var PORT:int = 5331;
		private var LOCALHOST:String = "127.0.0.1";
		private var dataString:String;
		
		public function Main(target:IEventDispatcher = null) {
			// constructor code
			socket = new XMLSocket();
			socket.addEventListener(DataEvent.DATA, onDataRecieved);
			socket.connect(LOCALHOST, PORT);
		}
		
		protected function onDataRecieved(event:DataEvent):void {
			dataString = new String(event.data.toString());
			trace(dataString);
			sensorData.text = dataString;
			
		}
	}
	
}
