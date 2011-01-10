package com.gltovar.babelflash
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.describeType;
	
	/**
	 *  Copyright (c) 2011  G. Louis Tovar 
	 *	
	 *	Permission is hereby granted, free of charge, to any person obtaining a copy
	 *	of this software and associated documentation files (the "Software"), to deal
	 *	in the Software without restriction, including without limitation the rights
	 *	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	 *	copies of the Software, and to permit persons to whom the Software is
	 *	furnished to do so, subject to the following conditions:
	 *	
	 *	The above copyright notice and this permission notice shall be included in
	 *	all copies or substantial portions of the Software.
	 *	
	 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	 *	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	 *	THE SOFTWARE.
	 * 
	 * @author Louis Tovar
	 * @link http://babelflash.gltovar.com
	 * 
	 * ===========================================================================
	 * **REQUIRES BULK LOADER** get it here: http://code.google.com/p/bulk-loader/
	 * ===========================================================================
	 * 
	 * Babel Flash v 0.9 - First public release 
	 *  
	 * Babel Flash allows for simpler localization for swfs. 
	 * It will load font swfs, and replace text and graphics with a simple lange change call.
	 * Setting up your swf can be done programatically or in the IDE... programmer and artist friendly.
	 * 
	 * The idea is that the LM parses though an xml and then keeps a dictionary of id's with the needed data to localize an asset.
	 * 
	 * When a Localized sprite is created it phones home to the LM, and its unique ID is its name (so it can be done in the IDE as well) so it is
	 * important that the sprites name is unique.
	 * 
	 * If an asset exists for the current language to replace the child in the sprite
	 * then it will be replaced with that asset / text
	 * 
	 * the Localized sprites also have an event listener on the LM so if the language changes on the fly, they all get updated properly.
	 * 
	 */
	[Event(name="languageChange", type="com.gltovar.babelflash.BabelFlashEvent")]
	[Event(name="ready", type="com.gltovar.babelflash.BabelFlashEvent")]
	
	public class BabelFlash extends EventDispatcher
	{
		private static var _instance:BabelFlash = new BabelFlash();
		public static function get instance():BabelFlash { return _instance; } 
		
		public function BabelFlash() 
		{
			if (_instance) throw Error('Singleton error, use BabelFlash.instance')
		}
		
		public static const LANGUAGE_ENGLISH:String = 'en';
		
		private var _currentLanguage:String = LANGUAGE_ENGLISH;
		public function get currentLanguage():String { return _currentLanguage; }
		
		private var _localizedAssetManager:LocalizedAssetManager = new LocalizedAssetManager();
		
		private var _bulkLoader:BulkLoader = new BulkLoader('BabelFlash');
		
		private var _ready:Boolean = false;
		public function get ready():Boolean { return _ready; }
		
		public function changeLanguage(p_language:String):void
		{
			_currentLanguage = p_language;
			
			dispatchEvent( new BabelFlashEvent(BabelFlashEvent.LANGUAGE_CHANGE) );
		}
		
		/**
		 * Will handle loading and parsing of a localized xml string. uses bulk loader
		 * @param	p_xmlPath - the location of the localize xml file
		 */
		public function loadLocalizationXML(p_xmlPath:String):void
		{
			
			_bulkLoader.add(p_xmlPath);
			_bulkLoader.get(p_xmlPath).addEventListener(Event.COMPLETE, onXMLLoadComplete, false, 0, true);
			_bulkLoader.start();
		}

		private function onXMLLoadComplete(e:Event):void 
		{
			parseXMLFonts( new XML( (e.currentTarget as LoadingItem)._content ) );
		}
		
		private var _localizedFonts:Array = new Array();
		private var _localizedGraphicAssets:Array = new Array();
		private var _localizationXML:XML;
		private function parseXMLFonts(p_localizationXML:XML):void
		{
			
			_localizationXML = p_localizationXML;
			
			// queue to load external fonts
			var fonts:XMLList = p_localizationXML.fonts..externalfont
			var externalFont:XML;
			for each(externalFont in fonts)
			{
				var fontList:Array = new Array();
				
				var fontNames:XMLList = externalFont..fontname;
				var fontName:XML;
				for each(fontName in fontNames)
				{
					trace(fontName.toString());
					fontList.push(fontName.toString());
				}
				
				var fontLoader:FontLoader = new FontLoader();
				fontLoader.addEventListener(FontLoader.COMPLETE, onFontLoaded, false, 0, true);
				_localizedFonts.push(fontLoader);
				fontLoader.loadFont( externalFont.content.toString(), fontList );
				
				//_bulkLoader.add( externalFont.content.toString(), { id: externalFont.fontname.toString() } );
			}
			
			if (_localizedFonts.length == 0)
			{
				parseXMLData(_localizationXML);
			}
		}
		
		private function onFontLoaded(e:Event):void 
		{
			_localizedFonts.splice( e.currentTarget, 1 );
			if (_localizedFonts.length == 0)
			{
				trace('finished loading fonts');
				parseXMLData(_localizationXML);
			}
		}
		
		private function parseXMLData(p_localizationXML:XML):void
		{
			
			// filter languages
			var locales:XMLList = p_localizationXML..locale;
			var locale:XML;
			for each(locale in locales)
			{
				var language:String = locale.language.toString();
				trace('lang: ' + language);
				
				// iterate though the various localized text assets
				var textAssets:XMLList = locale..textasset;
				var textAsset:XML;
				var node:XML;
				for each(textAsset in textAssets)
				{
					
					var localizedTextAssetData:LocalizedTextAssetData = new LocalizedTextAssetData();
					localizedTextAssetData.language = language;
					parseAssetData(textAsset, localizedTextAssetData);
					
					// interate though the unique properies of a text asset
					for each(node in textAsset.children())
					{
						switch( node.name().toString().toLowerCase() )
						{
							case 'content':
								localizedTextAssetData.content = node.toString();
								break;
							case 'align':
								if( !(node.toString() != TextFormatAlign.CENTER || node.toString() != TextFormatAlign.LEFT || node.toString() != TextFormatAlign.RIGHT || node.toString() != TextFormatAlign.JUSTIFY) )
								{
									throw Error('language: ' + language + ', asset id: ' + localizedTextAssetData.id + ' align value: ' + node.toString() + ' is not one of the constants in TextFormatAlign.');
								}
								localizedTextAssetData.textFormat.align = node.toString();
								localizedTextAssetData.loadedFormatProperties.align = true;
								break;
							case 'blockindent':
								if ( isNaN(Number(node.toString())) )
								{
									throw Error('language: ' + language + ', asset id: ' + localizedTextAssetData.id + ' block indent value: ' + node.toString() + ' is not a valid number.');
								}
								localizedTextAssetData.textFormat.blockIndent = Number(node.toString());
								localizedTextAssetData.loadedFormatProperties.blockIndent = true;
								break;
							case 'bold':
								localizedTextAssetData.textFormat.bold = stringBooleanHandler( node.toString() );
								localizedTextAssetData.loadedFormatProperties.bold = true;
								break;
							case 'bullet':
								localizedTextAssetData.textFormat.bullet = stringBooleanHandler( node.toString() );
								localizedTextAssetData.loadedFormatProperties.bullet = true;
								break;
							case 'color':
								localizedTextAssetData.textFormat.color = createColor( node.toString() );
								localizedTextAssetData.loadedFormatProperties.color = true;
								break;
							case 'font':
								localizedTextAssetData.textFormat.font = node.toString();
								localizedTextAssetData.loadedFormatProperties.font = true;
								break;
							case 'indent':
								if ( isNaN(Number(node.toString())) )
								{
									throw Error('language: ' + language + ', asset id: ' + localizedTextAssetData.id + ' indent value: ' + node.toString() + ' is not a valid number.');
								}
								localizedTextAssetData.textFormat.indent = Number(node.toString());
								localizedTextAssetData.loadedFormatProperties.indent = true;
								break;
							case 'italic':
								localizedTextAssetData.textFormat.italic = stringBooleanHandler( node.toString() );
								localizedTextAssetData.loadedFormatProperties.italic = true;
								break;
							case 'kerning':
								if ( isNaN(Number(node.toString())) )
								{
									throw Error('language: ' + language + ', asset id: ' + localizedTextAssetData.id + ' kerning value: ' + node.toString() + ' is not a valid number.');
								}
								localizedTextAssetData.textFormat.kerning = Number(node.toString());
								localizedTextAssetData.loadedFormatProperties.kerning = true;
								break;
							case 'leading':
								if ( isNaN(Number(node.toString())) )
								{
									throw Error('language: ' + language + ', asset id: ' + localizedTextAssetData.id + ' leading value: ' + node.toString() + ' is not a valid number.');
								}
								localizedTextAssetData.textFormat.leading = Number(node.toString());
								localizedTextAssetData.loadedFormatProperties.leading = true;
								break;
							case 'leftmargin':
								if ( isNaN(Number(node.toString())) )
								{
									throw Error('language: ' + language + ', asset id: ' + localizedTextAssetData.id + ' left margin value: ' + node.toString() + ' is not a valid number.');
								}
								localizedTextAssetData.textFormat.leftMargin = Number(node.toString());
								localizedTextAssetData.loadedFormatProperties.leftMargin = true;
								break;
							case 'rightmargin':
								if ( isNaN(Number(node.toString())) )
								{
									throw Error('language: ' + language + ', asset id: ' + localizedTextAssetData.id + ' right margin value: ' + node.toString() + ' is not a valid number.');
								}
								localizedTextAssetData.textFormat.rightMargin = Number(node.toString());
								localizedTextAssetData.loadedFormatProperties.rightMargin = true;
								break;
							case 'size':
								if ( isNaN(Number(node.toString())) )
								{
									throw Error('language: ' + language + ', asset id: ' + localizedTextAssetData.id + ' size value: ' + node.toString() + ' is not a valid number.');
								}
								localizedTextAssetData.textFormat.size = Number(node.toString());
								localizedTextAssetData.loadedFormatProperties.size = true;
								break;
							case 'tabstops':
								throw Error('tab stops not implemented');
								break;
							case 'target':
								localizedTextAssetData.textFormat.target = node.toString();
								localizedTextAssetData.loadedFormatProperties.target = true;
								break;
							case 'underline':
								localizedTextAssetData.textFormat.underline = stringBooleanHandler(node.toString());
								localizedTextAssetData.loadedFormatProperties.underline = true;
								break;
							case 'url':
								localizedTextAssetData.textFormat.url = node.toString();
								localizedTextAssetData.loadedFormatProperties.url = true;
								break;
								
						}
					}
					
					_localizedAssetManager.addLocalizedAssetData(localizedTextAssetData);
				}
				
				// iterate though the localized graphic data
				var graphicAssets:XMLList = locale..graphicasset;
				var graphicAsset:XML;
				for each(graphicAsset in graphicAssets)
				{
					var localizedGraphicAssetData:LocalizedGraphicAssetData = new LocalizedGraphicAssetData();
					localizedGraphicAssetData.language = language;
					parseAssetData(graphicAsset, localizedGraphicAssetData);
					
					// iterate though the unique graphic data content
					for each(node in graphicAsset.children())
					{
						switch(node.name().toString())
						{
							case 'content':
								localizedGraphicAssetData.contentPath = node.toString();
								break;
						}
						
					}
					
					_bulkLoader.add( localizedGraphicAssetData.contentPath, {id: (language + localizedGraphicAssetData.id)} );
					_localizedGraphicAssets.push( (language + localizedGraphicAssetData.id) )
										
					_localizedAssetManager.addLocalizedAssetData(localizedGraphicAssetData);
				}
			}
			
			// load all assets at once
			_bulkLoader.addEventListener(BulkProgressEvent.COMPLETE, onGraphicLoadComplete, false, 0, true);
			_bulkLoader.start()
			
			if ( !_localizedGraphicAssets.length )
			{
				_ready = true;
				dispatchEvent(new BabelFlashEvent(BabelFlashEvent.READY) );
			}
		}
		
		/**
		 * this converts various strings into uint colors
		 * @param	token
		 * @return
		 */
		private function createColor(token:String):uint 
		{
			var color:uint = 0;
			if(!token)
			{
				// return zero
			}
			else if(token.substr(0, 1) == "#") {
				color = uint("0x" + token.substr(1));
			} else if(token.substr(0, 2) == "0x") {
				color = uint(token);
			}
			return color;
		}
		
		/**
		 * this handles how to convert a string to a boolean smartly.
		 * @param	p_booleanString
		 * @return
		 */
		private function stringBooleanHandler(p_booleanString:String):Boolean
		{
			var result:Boolean;
			
			if ( Number(p_booleanString) == 0)
			{
				result = false;
			}
			else if ( p_booleanString.toLowerCase() == 'true' || Number(p_booleanString) == 1 )
			{
				result = true;
			}
			else
			{
				result = Boolean( p_booleanString );
			}
			
			return result;
		}
		
		/**
		 * when a graphic items content has finished loading store it in the appropriate asset holder
		 * @param	e
		 */
		private function onGraphicLoadComplete(e:Event):void 
		{
			while (_localizedGraphicAssets.length)
			{
				trace(_localizedGraphicAssets[0]);
				( _localizedAssetManager.getLocalizedAssetDataFromKey( _localizedGraphicAssets[0]) as LocalizedGraphicAssetData ).content = _bulkLoader.getContent( _localizedGraphicAssets[0] );
				_localizedGraphicAssets.shift();
			}
			
			_ready = true;
			dispatchEvent(new BabelFlashEvent(BabelFlashEvent.READY) );
			trace('finished loading');
		}
		
		/**
		 * Both text data and graphic data have similar properties, so this handles those similarities 
		 * @param	p_assetXML
		 * @param	p_localizedAssedData
		 * @return
		 */
		private function parseAssetData(p_assetXML:XML, p_localizedAssedData:LocalizedAssetData):LocalizedAssetData
		{	
			for each(var node:XML in p_assetXML.children())
			{
				switch(node.name().toString())
				{
					case 'id':
						p_localizedAssedData.id = node.toString();
						break;
					case 'x':
						p_localizedAssedData.x = node.toString();
						break;
					case 'y':
						p_localizedAssedData.y = node.toString();
						break;
					case 'width':
						p_localizedAssedData.width = node.toString();
						break;
					case 'height':
						p_localizedAssedData.height = node.toString();
						break;
					case 'rotation':
						p_localizedAssedData.rotation = node.toString();
						break;
				}
			}
			
			trace(p_localizedAssedData.id);
			
			return p_localizedAssedData;
		}
		
		/**
		 * if already have localized sml (either xml in AS or loaded it your own way, pass it in here)
		 * @param	p_localizationXML - the localize xml
		 */
		public function receiveLocalizationXML(p_localizationXML:XML):void 
		{
				parseXMLFonts(p_localizationXML);
		}
		
		/**
		 * this method is the check in for the localizedSprite.
		 * @param	p_localizedSprite - the asset o check for localization
		 */
		public function localizeAsset(p_localizedSprite:BabelFlashSprite):void
		{
			if ( !_ready ) throw Error('Babel Flash is not ready to accept yor request.  Check for BabelFlash.instance.ready or add the LocalizeEvent.READY listener');
			
			if (p_localizedSprite.numChildren != 1) throw Error('LocalizedSprite NEEDS to have only 1 child.');
			
			
			trace('starting to localize asset');
			
			var localizedAssetData:LocalizedAssetData = _localizedAssetManager.getLocalizedAssetDataFromId(p_localizedSprite.name, _currentLanguage);
			
			var propertiesXMLList:XMLList 
			var key:String;
			// if its a textfield update it based on the current language.
			if (localizedAssetData is LocalizedTextAssetData)
			{
				if (p_localizedSprite.getChildAt(0) is TextField)
				{
					var textfield:TextField = p_localizedSprite.getChildAt(0) as TextField;
				}
				else
				{
					throw Error('The xml data lists this item as a textfield, but there is no textfield in this LocalizedSprite');
				}
				
				var textFormat:TextFormat = textfield.defaultTextFormat;
				
				propertiesXMLList = describeType( (localizedAssetData as LocalizedTextAssetData).loadedFormatProperties )..variable.@name;
				
				for each(key in propertiesXMLList)
				{
					if ( (localizedAssetData as LocalizedTextAssetData).loadedFormatProperties[key] )
					{
						textFormat[key] = (localizedAssetData as LocalizedTextAssetData).textFormat[key];
						
						// need switch embedfonts on and off depending if the font was loaded in.
						if (key == 'font')
						{		
							textfield.embedFonts = false;
							
							var font:Font;
							for each(font in Font.enumerateFonts())
							{
								if (font.fontName == textFormat[key])
								{
									textfield.embedFonts = true;
								}
								
							}
						}
					}
					trace(textFormat[key]);
				}
				
				textfield.text = (localizedAssetData as LocalizedTextAssetData).content;
				textfield.setTextFormat( textFormat );
			}
			else if (localizedAssetData is LocalizedGraphicAssetData)
			{
				// if its a graphic, replace the existing graphic with appropriate content.
				
				p_localizedSprite.removeChildAt(0);
				
				var graphicContent:DisplayObject = (localizedAssetData as LocalizedGraphicAssetData).content as DisplayObject;
				
				p_localizedSprite.addChild( graphicContent );
				
				propertiesXMLList = describeType( (localizedAssetData) )..variable.@name;
				
				trace(propertiesXMLList.toXMLString());
				
				for each(key in propertiesXMLList)
				{
					if ( graphicContent.hasOwnProperty(key) )
					{
						if( localizedAssetData[key] is Number && !isNaN(localizedAssetData[key]) )
						{		
							graphicContent[key] = localizedAssetData[key];
						}
					}
				}
			}
		}
			
	}

}