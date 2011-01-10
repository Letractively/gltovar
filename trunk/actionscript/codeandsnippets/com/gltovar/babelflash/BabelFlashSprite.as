package com.gltovar.babelflash 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * The LocalizedSprite contains one child that is targeted to be replaced with region/locale specific art/text
	 * 
	 * There can only be ONE child in this, it is the assumption I am making.
	 * 
	 * @author Louis Tovar
	 */
	public class BabelFlashSprite extends Sprite
	{
		
		/**
		 * If you are building this programmatically then make sure to construct with the correct name,
		 * and the content (graphic / textfield) that will default / be replaced. nameId is manditory if 
		 * creating LocalizeSprite programatically.
		 * @param	p_nameId
		 * @param	p_content
		 */
		public function BabelFlashSprite(p_nameId:String = null, p_content:DisplayObject = null) 
		{
			if (p_nameId != null)
			{
				this.name = p_nameId;
			}
			
			if (p_content != null)
			{
				this.addChild( p_content );
			}
			
			if (BabelFlash.instance.ready){ init(); }
			else { BabelFlash.instance.addEventListener(BabelFlashEvent.READY, onLocalizationManagerReady, false, 0, true); }
			
		}
		
		private function init():void
		{
			BabelFlash.instance.addEventListener(BabelFlashEvent.LANGUAGE_CHANGE, onLanguageChange, false, 0, true);
			BabelFlash.instance.localizeAsset(this);
		}
		
		private function onLocalizationManagerReady(e:BabelFlashEvent):void
		{
			BabelFlash.instance.removeEventListener(BabelFlashEvent.READY, onLocalizationManagerReady);
			init();
		}
		
		private function onLanguageChange(e:BabelFlashEvent):void 
		{
			BabelFlash.instance.localizeAsset(this);
		}
		
	}

}