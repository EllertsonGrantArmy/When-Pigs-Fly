package objects
{
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Hero;
	import citrus.objects.platformer.nape.Hills;
	import citrus.physics.nape.NapeUtils;
	
	import levels.LevelTwo;
	
	import nape.callbacks.InteractionCallback;
	import nape.phys.Body;
	import nape.phys.Material;
	
	import starling.utils.deg2rad;
	
	public class FlyingHero extends Hero
	{
		public function FlyingHero(name:String, params:Object=null)
		{
			super(name, params);
			offsetX = -10;
		}
		
		public function _updateAnimation(jh:int):void
		{			
			_body.mass = 5;
			_body.velocity.x = 120;
			
			//if receiveing data from device
			if(jh > 0 && int(_body.velocity.x) <= 300 && int(_body.velocity.y) >= -350){
				_body.velocity.y -= jh/4;
				_body.velocity.x += jh/2;
				_body.mass = 1;
			}
			//slows pig back down if they're going too fast
			else if (jh <= 10 && int(_body.velocity.x) >= 120)
			{
				_body.velocity.x -= _body.velocity.x/20;
				
				//brings pig down vertically
				if(_body.velocity.y < 0)
					_body.velocity.y -= _body.velocity.y/50;
			}
			
			//keeps user at constant speed
			/*if(jh <= 10)
			{
				_body.velocity.x = 120;
				_body.velocity.y = 0;
			}*/
			
		}
		
		override protected function createMaterial():void
		{
			_material = Material.ice();
		}
		
		/*override public function handleBeginContact(callback:InteractionCallback):void
		{
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
			
			if (callback.arbiters.length > 0 && callback.arbiters.at(0).collisionArbiter) 
			{
				//if hero comes into contact with hills, update rotation of pig's vew
				if(collider is Hills)
				{
					var currRot:int = (deg2rad(-(collider as Hills).currentAmplitude));
					if((rotation <=  currRot + 3) && (rotation >=  currRot - 3))
						LevelTwo.ref.pigMC.rotation = deg2rad(currRot);
				}
			}
		}*/
		
	}
}