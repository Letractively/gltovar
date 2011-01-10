package com.gltovar.babelflash 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Louis Tovar
	 */
	public class BabelFlashEvent extends Event 
	{
		public static const LANGUAGE_CHANGE:String = 'languageChange';
		public static const READY:String = 'ready';
		
		public function BabelFlashEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new BabelFlashEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("LocalizeEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}