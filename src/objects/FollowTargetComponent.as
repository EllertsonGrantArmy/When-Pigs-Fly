package objects {

	import citrus.core.CitrusGroup;
	import citrus.objects.NapePhysicsObject;
	import citrus.system.Component;
	
	import starling.utils.deg2rad;

	/**
	 * @author Aymeric
	 */
	public class FollowTargetComponent extends Component {
		
		public var follow:NapePhysicsObject = new NapePhysicsObject("pig");

		public function FollowTargetComponent(name:String, params:Object = null) {
			super(name, params);
			
		}

		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			var i:int = 0;
			//update the x and y position for each feather in the pig group to move with the pig hero
			for each (var object:Object in (entity as CitrusGroup).groupObjects) {
				
				if (follow != object) {
					
					if(i % 2 == 0){
						object.x = 35 + follow.x + (i*2);
						object.y = -25 + follow.y + (i*8);
					}
					else
					{
						object.x = -35 + follow.x - ((i-1)*2);
						object.y = -25 + follow.y + ((i-1)*8);
					}
					
					i++;
				}
				
			}
		}

	}
}
