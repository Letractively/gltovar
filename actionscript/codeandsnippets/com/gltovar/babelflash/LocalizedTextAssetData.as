package com.gltovar.babelflash 
{
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Louis Tovar
	 */
	public class LocalizedTextAssetData extends LocalizedAssetData
	{
		public var content:String = null;
		public var textFormat:TextFormat = new TextFormat();
		public var loadedFormatProperties:LoadedFormatProperties = new LoadedFormatProperties();
	}

}