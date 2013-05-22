package objects
{
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Enemy;
	import citrus.physics.nape.NapeUtils;
	
	import levels.LevelOne;
	import levels.LevelTwo;
	
	import nape.callbacks.InteractionCallback;
	
	public class Bird extends Enemy
	{
		//the bird doesn't disappear right away when killed so 
		//we need a variable that allows them to only be hit once
		private var killable:Boolean = true;
		
		public function Bird(name:String, params:Object=null)
		{
			super(name, params);
			
			//horizontal speed (x axis)
			speed = 25;
		}
		
		
		override public function handleBeginContact(callback:InteractionCallback):void
		{
			//collider is other object that bird comes into contact with
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
			
			if (callback.arbiters.length > 0 && callback.arbiters.at(0).collisionArbiter) {
				
				/**
				 * if bird hits hero (pig), don't kill initially
				 * kill in LevelOne's hitBird() function
				 * */
				if(collider is JumpingHero)
				{
					kill = false;
						
					if(killable){
						killable = false;
						LevelOne.ref.hitBird(this);
					}
				}
				else if (collider is FlyingHero)
				{
					kill = true;
					//(collider as FlyingHero).hurt();
					LevelTwo.ref.addX();
				}
				//no contact with other bodies
				else if (collider is MyPlatform || collider is Bird)
					return;
			}
		}
		
		override public function update(timeDelta:Number):void
		{
			//to flip view
			if ((_inverted && x < leftBound) || (!_inverted && x > rightBound))
				turnAround();
			
				//if going left, velocity is -speed, otherwise speed
				_body.velocity.x = _inverted ? -speed : speed;

				//keep body slightly afloat by changing the gravitational mass every other frame
				_body.gravMass = _body.gravMass == 0.15 ? -.15 : .15;
			}		
	}
}