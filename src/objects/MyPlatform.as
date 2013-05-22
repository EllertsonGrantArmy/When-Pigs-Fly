package objects
{
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.MovingPlatform;
	import citrus.physics.nape.NapeUtils;
	
	import levels.LevelOne;
	
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	
	public class MyPlatform extends MovingPlatform
	{
		private var _oneWay:Boolean = true; //so hero can come up from below platform and land on top
		
		public function MyPlatform(name:String, params:Object=null)
		{
			super(name, params);
		}
		
		
		override public function update(timeDelta:Number):void
		{
			//if the game is not paused, move the platforms
			if(!LevelOne.ref.paused){
				super.update(timeDelta);
			}
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void
		{
			//allow pig to ride platform
			var other:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
			if(other.name == "pig")
				_passengers.push(other.body);
		}
		
		
	}
}