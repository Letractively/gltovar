package 
{
	import com.bit101.components.IndicatorLight;
	import com.bit101.components.PushButton;
	import com.bit101.components.Text;
	import com.bit101.components.Window;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import louistovar.pausetimer.PauseTimer;
	
	/**
	 * Quick demo of the pause timer in use.
	 * @author Louis Tovar
	 */
	public class Main extends Sprite 
	{
		private var _outputWindow:Window;
		private var _indicatorLightTimerTick:IndicatorLight;
		private var _buttonPauseTimer:PushButton;
		private var _pauseTimer:PauseTimer;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			// create minimalcomps display components.  http://www.minimalcomps.com/
			_outputWindow = new Window(this, 60, 20, 'Pause Timer');
			_outputWindow.width = 125;
			_indicatorLightTimerTick = new IndicatorLight(_outputWindow, 15, 35, 0x00FF00, ' timer tick 1 sec');
			
			// this minimalcomps button will trigger the pause.
			_buttonPauseTimer = new PushButton(_outputWindow, 10, 65, 'Pause Timer', onButtonPress);
				
			// create new PauseTimer and treat it the same way was the regular timer
			_pauseTimer = new PauseTimer(1500, 0);
			_pauseTimer.addEventListener(TimerEvent.TIMER, onTick);
			_pauseTimer.start();
		}
		
		private function onTick(e:TimerEvent):void 
		{
			_indicatorLightTimerTick.isLit = !_indicatorLightTimerTick.isLit;
		}
		
		/**
		 * This function shows the pause and resume functions for the PauseTimer
		 * @param	e
		 */
		private function onButtonPress(e:MouseEvent):void
		{
			if (_pauseTimer.paused)
			{
				_buttonPauseTimer.label = 'Pause Timer';
				_pauseTimer.resume();
			}
			else
			{
				_buttonPauseTimer.label = 'Resume Timer';
				_pauseTimer.pause();
			}
		}
		
	}
	
}