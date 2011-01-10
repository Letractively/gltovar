package com.gltovar.babelflash 
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.text.Font;
	
	/**
	 * ...
	 * @author Louis Tovar
	 */
	public class FontLoader extends EventDispatcher
	{
		public static const COMPLETE:String = 'loadFontComplete';
		public static const ERROR:String = 'loadFontError';
		
		private var _loader:Loader = new Loader();
		private var _fontsDomain:ApplicationDomain;
		private var _fontNames:Array;
		
		public function FontLoader():void
		{
			// empty
		}
		
		public function loadFont(p_path:String, p_fontNames:Array):void 
		{
			_fontNames = p_fontNames;
			trace('loading');
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onFontLoadIOError, false, 0, true);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onFontComplete, false, 0, true);
			
			_loader.load( new URLRequest(p_path));
		}
		
		private function onFontComplete(e:Event):void 
		{
			_fontsDomain = _loader.contentLoaderInfo.applicationDomain;
			registerFonts(_fontNames);
			dispatchEvent(new Event(FontLoader.COMPLETE));
		}
		
		private function onFontLoadIOError(e:IOErrorEvent):void 
		{
			dispatchEvent( new Event(FontLoader.ERROR) );
		}
		
		public function registerFonts(p_fontList:Array):void
		{
			var fontName:String;
			for each(fontName in p_fontList)
			{
				trace('fontName: ' + fontName);
				Font.registerFont(getFontClass(fontName));
			}
		}
		
		public function getFontClass(p_id:String):Class 
		{
			var result:Class;
			
			try
			{
				result = _fontsDomain.getDefinition(p_id) as Class;
			}
			catch (e:Error)
			{
				throw Error('The font name "' + p_id + '" was not found in the font swf that was loaded.');
			}
			
			return result;
		}
		
		public function getFont(p_id:String):Font
		{
			var fontClass:Class = getFontClass(p_id);
			return new fontClass as Font;
		}
		
	}

}