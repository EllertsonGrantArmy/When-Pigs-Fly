package objects
{
	import citrus.objects.NapePhysicsObject;
	import citrus.physics.nape.NapeUtils;
	
	import levels.LevelOne;
	
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	
	public class Feather extends NapePhysicsObject
	{
		public function Feather(name:String, params:Object=null)
		{
			super(name, params);
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);	
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void
		{
			//collider is other object feather comes into contact with
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);			
			
			//if collider is hero, call catchFeather() function and kill feather
			if(collider is JumpingHero){
				LevelOne.ref.catchFeather();
				kill = true;
			}
			//we don't want the feather to land on a cloud
			if (collider is MyPlatform && collider.y < y)	
				return;
		}
		
	}
}