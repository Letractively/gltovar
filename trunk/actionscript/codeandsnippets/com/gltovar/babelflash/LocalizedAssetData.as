package com.gltovar.babelflash 
{
	import flash.text.TextFormat;
	/**
	 * A structured piece of data that holds the information for each localiztion piece
	 * @author Louis Tovar
	 */
	public class LocalizedAssetData
	{
		public var id:String;
		public var language:String;
		public var x:Number = NaN;
		public var y:Number = NaN;
		public var width:Number = NaN;
		public var height:Number = NaN;
		public var rotation:Number = NaN;
	}

}