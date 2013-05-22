package core {
	import flash.errors.IOError;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.XMLSocket;
	import flash.utils.Timer;
	
	import starling.display.Sprite;
	import starling.events.Event;

	public class Calibrate extends Sprite {
		private static const PORT:int = 5331;
		private static const LOCALHOST:String = "127.0.0.1";
		
		private var socket:XMLSocket;
		private var minRest:int;
		private var maxRest:int;
		private var dataString:int;
		private var restVal:int;
		private var fail:Boolean = true;
    	private var toggleText:String;
		
    /**
    * Sets the value of toggleText based on the string passed in and then
    * creates a new instance of an XMLSocket(needed to get data from the Arduino)
    * then calls init
    * */
		public function Calibrate(toggleText:String) {
      		this.toggleText = toggleText;
			socket = new XMLSocket();
			init();
		}
    
    /**
     * Recieves data from the socket, if the user has selected the pressure sensor,
     * the reciever listens for data from the analog port 0 on the Ardunio device, 
     * if the muscle sensors have been selected, then we listen from port 1. 
     * 
     * The max and min rest values are then set accoringly
     * */
    protected function dataReceiver(event:DataEvent):void {
		fail = false;
      if(toggleText == "Pressure Sensor") {
        if(event.data.substr(0,2) == "A0") {
          dataString = parseInt(event.data.substring(2,6));
        }
      } else if(toggleText == "Muscle Sensor") {
        if(event.data.substr(0,2) == "A1") {
          dataString = parseInt(event.data.substring(2,6));
        }
      }
      
      if(minRest == 0) {
        minRest = dataString;
      }
      if(maxRest == 0) {
        maxRest = dataString;
      }
      if (minRest >= dataString) {
        minRest = dataString;
      }
      if (maxRest <= dataString) {
        maxRest = dataString;
      }
    }
    
    /**
     * Closes the socket connection, sets the trigger value for which the
     * cow will jump when the sensor value exceeds it and dispatches a new
     * event stating that calibration is complete
     * */
    protected function finishCalibrate(event:TimerEvent):void {
		if(fail != true) {
			socket.close();
			socket.removeEventListener(DataEvent.DATA, dataReceiver);
			trace("Max rest: " + maxRest + " Min Rest: " + minRest);
			restVal = (maxRest + minRest)/2 + 80;
			this.dispatchEvent(new starling.events.Event("CALIBRATE_COMPLETE"));
		} else {
			this.dispatchEvent(new starling.events.Event("ARDUINO_ERROR"));
		}
      
    }
		
		/**
    * Creates a new connection to the socket, adds an event listener that recieves
    * any data from the socket, adds a timer for two seconds to allow for calibration
    * and calls finishCalibrate when the timer ends
    * */
		private function init():void {
			trace("Calibrating");
			minRest = 0;
			maxRest = 0;
			socket.connect(LOCALHOST, PORT);
			socket.addEventListener(flash.events.Event.CONNECT, socketConnected);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}
		
		private function onIOError(e:IOErrorEvent):void {
			trace(e.text);
			this.dispatchEvent(new starling.events.Event("SOCKET_ERROR"));
		}
		
		private function socketConnected(e:flash.events.Event):void {			
			socket.addEventListener(DataEvent.DATA, dataReceiver);
			var myTimer:Timer = new Timer(2000, 1);
			myTimer.start();
			myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, finishCalibrate);
		}
	}
}