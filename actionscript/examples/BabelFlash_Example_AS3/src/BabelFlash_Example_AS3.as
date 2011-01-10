package
{
	import com.gltovar.babelflash.BabelFlash;
	import com.gltovar.babelflash.BabelFlashEvent;
	import com.gltovar.babelflash.BabelFlashSprite;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class BabelFlash_Example_AS3 extends Sprite
	{
		private var testBabelGraphic:BabelFlashSprite;
		private var testBabelText:BabelFlashSprite;
		
		public function BabelFlash_Example_AS3()
		{
			renderStartingGraphics();
			
			BabelFlash.instance.addEventListener(BabelFlashEvent.READY, onBabelFlashReady);
			BabelFlash.instance.loadLocalizationXML('testdata.xml');
		}
		
		private function renderStartingGraphics():void
		{
			var startingSprite:Sprite = new Sprite();
			startingSprite.graphics.beginFill(0xFF0000, 1);
			startingSprite.graphics.drawCircle(0,0,50);
			startingSprite.graphics.endFill();
			
			testBabelGraphic = new BabelFlashSprite('graphic_test', startingSprite);
			
			addChild(testBabelGraphic);
			testBabelGraphic.x = 100;
			testBabelGraphic.y = 100;
			
			testBabelGraphic.addEventListener(MouseEvent.CLICK, changeLanguage);
			
			var startingText:TextField = new TextField();
			startingText.text = 'starting text';
			
			testBabelText = new BabelFlashSprite('text_test', startingText);
			
			addChild( testBabelText );
		}
		
		private function onBabelFlashReady(e:BabelFlashEvent):void
		{
			BabelFlash.instance.changeLanguage( 'en' );
		}
		
		private function changeLanguage(e:MouseEvent):void
		{
			if( BabelFlash.instance.currentLanguage == 'en' )
			{
				BabelFlash.instance.changeLanguage( 'sp' );
			}
			else
			{
				BabelFlash.instance.changeLanguage( 'en' );
			}
		}
		
	}
}