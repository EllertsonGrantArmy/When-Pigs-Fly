package objects
{
	import citrus.objects.platformer.nape.Coin;
	
	import levels.LevelTwo;
	
	import nape.callbacks.InteractionCallback;
	
	public class Apple extends Coin
	{
		public function Apple(name:String, params:Object=null)
		{
			super(name, params);
		}
		
		override public function handleBeginContact(interactionCallback:InteractionCallback):void {
			
			super.handleBeginContact(interactionCallback);
			
			//call LevelTwo's eat apple function when contacted with hero
			LevelTwo.ref.eatApple(interactionCallback);
		}
	}
}