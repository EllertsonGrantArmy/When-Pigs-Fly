package
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class Assets
	{
		//grassy green striped floor with barn
		[Embed(source="img/grassFloor.png")]
		private static var ground:Class;
		public static var groundT:Texture;
		
		//blue sky background
		[Embed(source="img/skyBg.png")]
		private static var back:Class;
		public static var backT:Texture;
		
		//texture atlas png created
		[Embed(source="assets/atlas.png")]
		private static var atlas:Class;
		public static var ta:TextureAtlas;
		
		//texture atlas xml
		[Embed(source="assets/atlas.xml", mimeType="application/octet-stream")]
		private static var atlasXML:Class;	
		
		//particles for when bird hit
		[Embed(source="assets/starParticle.pex", mimeType="application/octet-stream")]
		public static var starParticle:Class;
		
		//particle for when feather caught
		[Embed(source="assets/coolParticle.pex", mimeType="application/octet-stream")]
		public static var coolParticle:Class;
		
		[Embed(source="assets/sounds/levelTwoBgm.mp3")]
		private static var levelTwoBgmClass:Class;
		public static var levelTwoBgm:Sound;
		
		[Embed(source="assets/sounds/bird_tweet.mp3")]
		private static var birdTweetClass:Class;
		public static var birdTweet:Sound;
		
		[Embed(source="assets/sounds/wing_flap.mp3")]
		private static var wingFlapClass:Class;
		public static var wingFlap:Sound;
		
		public static var myChannel:SoundChannel;
		public static var myChannelTwo:SoundChannel;
		
		public static function init():void
		{
			backT = Texture.fromBitmap(new back());
			groundT = Texture.fromBitmap(new ground());
			
			//setup texture atlas
			ta = new TextureAtlas(Texture.fromBitmap(new atlas()), XML(new atlasXML()));	
			
			levelTwoBgm = new levelTwoBgmClass();
			birdTweet = new birdTweetClass();
			wingFlap = new wingFlapClass();
			myChannel = new SoundChannel();
			myChannelTwo = new SoundChannel();
		}
	}
}