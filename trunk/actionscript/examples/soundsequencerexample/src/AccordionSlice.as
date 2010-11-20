package  
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.Text;
	import com.bit101.components.Window;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * This handles the drawing of an accordion slice as well as exposing the needed information about the slice
	 * @author Louis Tovar
	 */
	public class AccordionSlice extends EventDispatcher 
	{
		private var _slice:Window;
		private var _soundEnabled:CheckBox;
		private var _soundDelay:Text;
		private var _soundDelayLabel:Label;
		
		private var _soundName:String;
		
		public function AccordionSlice( p_sliceWindow:Window, p_soundName:String ) 
		{
			_slice = p_sliceWindow;
			_soundName = p_soundName;
			
			drawSliceGUI(p_soundName);
		}
		
		private function drawSliceGUI(p_soundName:String):void 
		{
			_soundDelay = new Text( _slice.content, 20, 20, '500' );
			_soundDelay.height = 20;
			_soundDelay.width = 40; 
			
			_soundDelayLabel = new Label( _slice.content, 70, 20, 'delay before playing in milliseconds' );
											
			_soundEnabled = new CheckBox( _slice.content,  20, 50, 'enable ' + p_soundName, onEnableChange );
			_soundEnabled.selected = true;
		}
		
		private function onEnableChange(e:Event):void 
		{
			if ( _soundEnabled.selected )
			{
				_soundDelay.enabled = true;
				_soundDelay.text = '500';
			}
			else
			{
				_soundDelay.enabled = false;
				_soundDelay.text = '0';
			}
			
		}
		
		public function get soundName():String { return _soundName; }
		public function get soundDelay():uint { return ( isNaN( uint(_soundDelay.text) ) ) ? 0 : uint(_soundDelay.text) ; }
		public function get soundEnabled():Boolean { return _soundEnabled.selected; }
	}

}