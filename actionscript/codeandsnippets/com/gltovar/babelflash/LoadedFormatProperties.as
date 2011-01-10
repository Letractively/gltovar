package com.gltovar.babelflash 
{
	import flash.text.TextFormat;
	/**
	 * This are set true if they were specified in the localization xml, so i know whether to use the existing text format properties or the ones from the xml
	 * @author Louis Tovar
	 */
	public class LoadedFormatProperties
	{
		public var align:Boolean;
		public var blockIndent:Boolean;
		public var bold:Boolean;
		public var bullet:Boolean;
		public var color:Boolean;
		public var font:Boolean;
		public var indent:Boolean;
		public var italic:Boolean;
		public var kerning:Boolean;
		public var leading:Boolean;
		public var leftMargin:Boolean;
		public var letterSpacing:Boolean;
		public var rightMargin:Boolean;
		public var size:Boolean;
		public var tabStops:Boolean;
		public var target:Boolean;
		public var underline:Boolean;
		public var url:Boolean;
	}

}