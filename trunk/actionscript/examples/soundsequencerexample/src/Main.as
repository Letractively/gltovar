package 
{
	import carlgloria.ai.interfaces.IPathManagerAsset;
	import com.bit101.components.Accordion;
	import com.bit101.components.CheckBox;
	import com.bit101.components.PushButton;
	import com.bit101.components.Text;
	import com.bit101.components.Window;
	import com.reintroducing.sound.SoundManager;
	import flash.display.Sprite;
	import flash.events.Event;
	import com.gltovar.soundsequence.SoundSequence;
	
	/**
	 * library requirements for example:
	 * Minimal Comps:  http://www.minimalcomps.com/
	 * Sound Manager: http://evolve.reintroducing.com/2008/07/15/as3/as3-soundmanager/
	 * Pause Timer: http://code.google.com/p/gltovar/source/browse/#svn/trunk/actionscript/codeandsnippets/com/gltovar/pausetimer
	 * Sound Sequencer: http://code.google.com/p/gltovar/source/browse/#svn/trunk/actionscript/codeandsnippets/com/gltovar/soundsequence
	 * 
	 * 
	 * This example shows of the use of sound sequencer.
	 * 
	 * Read more here: http://gltovar.com/blog/?p=173
	 * 
	 * @author Louis Tovar http://www.gltovar.com/blog
	 */
	public class Main extends Sprite 
	{
		public static const SOUND_1:String = 'sounds/beatloop.mp3';
		public static const SOUND_2:String = 'sounds/dial.mp3';
		public static const SOUND_3:String = 'sounds/saxfragment.mp3';
		
		public static const BUTTON_TEXT_PAUSE:String = 'Pause';
		public static const BUTTON_TEXT_UNPAUSE:String = 'Unpause';
		
		private var _window:Window;
		private var _sequenceAccordion:Accordion;
		private var _buttonPlaySequence:PushButton;
		private var _buttonStopSequence:PushButton;
		private var _buttonPauseSequence:PushButton;
		
		private var _accordionSlices:Array;
		
		private var _soundSequence:SoundSequence;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			//trace('hey!');
			
			initVars();
			initGUI();
			initSoundManager();
		}
		
		private function initVars():void
		{
			_accordionSlices = new Array();
		}
		
		/**
		 * used minimalcomps to display components.  http://www.minimalcomps.com/
		 */
		private function initGUI():void 
		{
			_window = new Window( this, 50, 25, "Sound Sequence" )
			_window.width = 300;
			_window.height = 240;
			
			_sequenceAccordion = new Accordion(_window.content, 20, 20 );
			_sequenceAccordion.width = 260;
			_sequenceAccordion.height = 180;
			
			_accordionSlices.push( addAccordionSlice( SOUND_1, 0 ) );
			_accordionSlices.push( addAccordionSlice( SOUND_2, 1 ) );
			_accordionSlices.push( addAccordionSlice( SOUND_3, 2 ) );
			
			_buttonPlaySequence = new PushButton( _window.content, 45, 180, 'Play', onPlaySequence );
			_buttonPlaySequence.width = 60;
			
			_buttonPauseSequence = new PushButton( _window.content, 115, 180, BUTTON_TEXT_PAUSE, onPauseSequence );
			_buttonPauseSequence.width = 60;
			_buttonPauseSequence.enabled = false;
			
			_buttonStopSequence = new PushButton( _window.content, 185, 180, 'Stop', onStopSequence );
			_buttonStopSequence.width = 60;
			_buttonStopSequence.enabled = false;
		}
		
		/**
		 * This is how to initialize external sounds with  Matt Przybylski's sound manager
		 * http://evolve.reintroducing.com/2008/07/15/as3/as3-soundmanager/
		 */
		private function initSoundManager():void 
		{
			SoundManager.getInstance().addExternalSound( SOUND_1, SOUND_1 );
			SoundManager.getInstance().addExternalSound( SOUND_2, SOUND_2 );
			SoundManager.getInstance().addExternalSound( SOUND_3, SOUND_3 );
		}
		
		/**
		 * This adds new accordion slices to the Minimal comps accordion. It comes with 2 free slices!!! ^_~
		 * @param	p_soundName - the name of the sound it manages
		 * @param	p_sliceIndex - the index of the accordion slice
		 * @return  An accordion Slice object that i can cycle though to get the info to create a sound sequence.
		 */
		private function addAccordionSlice( p_soundName:String, p_sliceIndex:int ):AccordionSlice
		{
			// minimal comps accordians come with 2 slices
			if ( p_sliceIndex > 1 ) _sequenceAccordion.addWindow( 'new slice' );
			
			var sliceWindow:Window = _sequenceAccordion.getWindowAt(p_sliceIndex);
			sliceWindow.title = 'Properties of ' + p_soundName
			
			var accordionSlice:AccordionSlice = new AccordionSlice( sliceWindow, p_soundName );
			
			return accordionSlice;
		}
		
		/**
		 * This handles the play button click. Will start a new sound sequence
		 * @param	e
		 */
		private function onPlaySequence(e:Event):void 
		{
			// stop a sequece if one is playing.
			stopSoundSequence();
			
			// lets go through each AccordionSlice and create a sequence based on the GUI info
			_soundSequence = new SoundSequence();
			var i:int;
			for (i = 0; i < _accordionSlices.length; i++)
			{
				var accordionSlice:AccordionSlice = _accordionSlices[i] as AccordionSlice;
				
				if ( accordionSlice.soundDelay != 0 ) _soundSequence.addDelay( accordionSlice.soundDelay );
				
				if ( accordionSlice.soundEnabled ) _soundSequence.addSound( accordionSlice.soundName );
			}
			
			_buttonPauseSequence.enabled = true;
			_buttonStopSequence.enabled = true;
			
			_soundSequence.addEventListener(Event.COMPLETE, onSoundSequenceComplete);
			_soundSequence.playSequence();
			
		}
		
		/**
		 * This shows off the ability to pause a running sequence (maybe if a game is paused = P)
		 * @param	e
		 */
		private function onPauseSequence(e:Event):void 
		{
			if (_soundSequence)
			{
				if ( _buttonPauseSequence.label == BUTTON_TEXT_PAUSE )
				{
					_soundSequence.pauseSequence();
					
					_buttonPauseSequence.label = BUTTON_TEXT_UNPAUSE;
				}
				else
				{
					_soundSequence.resumeSequence();
					
					_buttonPauseSequence.label = BUTTON_TEXT_PAUSE;
				}
			}
		}
		
		/**
		 * This shows you can stop a sequence at any time.
		 * @param	e
		 */
		private function onStopSequence(e:Event):void 
		{
			stopSoundSequence();
		}
		
		/**
		 * This handles stopping a sequence and removing listeners and disabling appropriate buttons
		 */
		private function stopSoundSequence():void 
		{
			if ( _soundSequence )
			{
				_soundSequence.stopSequence();
				_soundSequence.removeEventListener(Event.COMPLETE	, onSoundSequenceComplete);
			}
			
			_buttonPauseSequence.enabled = false;
			_buttonStopSequence.enabled = false; 
		}
		
		/**
		 * Handles the event when a sound sequence has finished playing
		 * @param	e
		 */
		private function onSoundSequenceComplete(e:Event):void 
		{
			_buttonPauseSequence.enabled = false;
			_buttonStopSequence.enabled = false;
		}
		
	}
	
}