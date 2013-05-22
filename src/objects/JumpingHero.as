package objects{
	
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Hero;
	import citrus.physics.nape.NapeUtils;
	
	import flash.utils.Timer;
	
	import levels.LevelOne;
	
	import nape.callbacks.InteractionCallback;
	
	public class JumpingHero extends Hero
	{
		public static var ref:JumpingHero; //reference of this class for other classes
		private var jumpFromX:int = 250;  //where the pig will jump from
		private var _currentY:int = 0;	//keep track of hero's y, if he jumps too far, level failed

		private const GRAV_MASS:int = 15; //gravitational mass of pig
		
		public function JumpingHero(name:String, params:Object=null)
		{
			JumpingHero.ref = this;
			
			super(name, params);
			
		}
		
		
		public function get currentY():int
		{
			return _currentY;
		}

		override public function update(timeDelta:Number):void
		{
			//this function runs automatically on every frame
			//we want jump height to be 0 so the hero isn't constantly jumping
			//false for can jump, this is only set from the main class with pressure

				_updateAnimation(false, 0);
		}
		
		public function _updateAnimation(canJump:Boolean, jh:int):void
		{
			body.gravMass = GRAV_MASS;
			//if onGround and y velocity is 0 (bec it fluctuates between 2 very small numbers on either side of 0)
			if(canJump && int(_body.velocity.y) >= 0)
			{
				_onGround = false; 
				_body.velocity.y = -jh; //jump up
				_body.gravMass = 0; //no gravitational mass
			}
			else
			{
				//fall back down after jump
				if(_body.velocity.y < 0)		
					_body.velocity.y -= _body.velocity.y/20;			
			}
			
			//updates jumpFromX; if this was not updated, hero would jump from the x position of which he landed on the cloud
			if(_onGround)
				jumpFromX = x;
			else
				x = jumpFromX;

			
			/**
			 * keeps hero on the stage if he tries to go
			 * too far to the left or right
			 **/	
			if(x >= 500)
				x = 500;
			else if(x <= 0)
				x = 0;
			
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void {
			
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);			
			
			
			if (callback.arbiters.length > 0 && callback.arbiters.at(0).collisionArbiter) {
				
				//if hero hits feather, call catchFeather() function and get rid of feather
				if(collider is Feather)
				{
					LevelOne.ref.catchFeather();
					collider.kill = true;
				}
				
				var collisionAngle:Number = callback.arbiters.at(0).collisionArbiter.normal.angle * 180 / Math.PI;
				
				if ((collisionAngle > 45 && collisionAngle < 135) || (collisionAngle > -30 && collisionAngle < 10) || collisionAngle == -90)
				{
					if (collisionAngle > 1 || collisionAngle < -1) {
						
						//we don't want the Hero to be set up as onGround if it touches a cloud.
						if (collider is MyPlatform && (collider as MyPlatform).oneWay && collider.y < y)	
							return;
						if(collider is MyPlatform && collider.y > y)
							_currentY = y;
						_groundContacts.push(collider.body);
						_onGround = true;
					}
				}
			}
		}
		
		public function getJumpFromX():int {
			return jumpFromX;
		}
		
	}
}