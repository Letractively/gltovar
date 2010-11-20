package com.gltovar.soundsequence
{
	import com.reintroducing.sound.SoundManager;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import louistovar.pausetimer.PauseTimer;
	
	/**
	 * when a sequence is done.
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 *  Copyright (c) 2010  G. Louis Tovar 
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
	 *	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*
	 * 
	 * This object handles playing sound with defined delays in the defined sequence.
	 * 
	 * This class relys on the soundmanager from http://evolve.reintroducing.com/2008/07/15/as3/as3-soundmanager/
	 * 		Make sure to read up on that site to see how to initialize sound in Matt Przybylski's code above.
	 * 
	 * @author Louis Tovar www.gltovar.com/blog
	 * 
	 * @version 1.0
	 * 				-	More features i'd like to add would be the ability to start a sound
	 * 					in a spot other than the beginning or end a sound sooner.
	 * 
	 * 			0.8
	 * 				-	Would like to add a pause and stop feature.
	 * 
	 * 
	 * @example few ways to use this:
	 * 
	 * method #1:
	 * var soundSequence:SoundSequence = new SoundSequence('sound1', 'sound2', 5000, 'sound3'); 
	 * 
	 * method #3:
	 * var soundArray:Array = ['sound1', 'sound2', 5000, 'sound3']
	 * var soundSequence:SoundSequence = new SoundSequence();
	 * soundSequence.sequenceFromArray( soundArray );
	 * 
	 * method #2:
	 * var soundSequence:SoundSequence = new SoundSequence();
	 * soundSequence.addSound('sound1');
	 * soundSequence.addSound('sound2');
	 * soundSequence.addDelay(5000);
	 * soundSequence.addSound('sound3');
	 * 
	 * ALL METHODS START THE SEQUENCE:
	 * soundSequence.start() // will play SoundManager's 'sound1' ID-ed sound1, then sound2, then 5 second gap, then sound3
	 * 
	 * soundSequence.addEventListener(Event.COMPLETE, onSoundSequenceComplete) // if you want to know when it is finished playing.
	 * 
	 */
	public class SoundSequence extends EventDispatcher
	{
		private var _sequenceArray:Array;
		private var _sequenceTimer:PauseTimer;
		private var _totalTime:Number;
		private var _currentTime:Number;
		private var _startTime:Number;
		private var _currentSequenceObject:Object;
		
		public function get sequenceLength():int
		{
			return _totalTime;
		}
		
		public function get currentTime():int
		{
			var result:int = 0;
			
			if (_startTime)
			{
				result = getTimer() - _startTime;
				
				if ( result > _totalTime)
				{
					result = _totalTime;
				}
			}
			
			return result;
		}
		
		/**
		 * Pass in SoundManager Ids and or numbers in the constructor to create a sequence.
		 * Alternatively have the constructor blank, and bring in your own array with SoundSequence.sequenceFromArray
		 * or put them in one at a time with SequenceArray.addSound and SequenceArray.addDelay
		 * @param	...args strings and ints for delay (in milliseconds) 
		 */
		public function SoundSequence(...args)
		{
			if (args.length)
			{
				var newArgs:Array = args as Array;
				_sequenceArray = newArgs;
				resetTotalTime();
			}
			else
			{
				_sequenceArray = new Array();
			}
		}
		
		/**
		 * an array that contains strings (SoundManager ids) and numbers (delay in milliseconds)
		 * @param	p_sequenceArray
		 * @return
		 */
		public function sequenceFromArray( p_sequenceArray:Array ):int
		{
			_sequenceArray = p_sequenceArray;
	
			resetTotalTime();
			return _totalTime;
		}
		
		/**
		 * SoundManager ids
		 * @param	p_soundId
		 * @return
		 */
		public function addSound( p_soundId:String ):int
		{
			_sequenceArray.push( p_soundId );
			resetTotalTime();
			return _totalTime;
		}
		
		/**
		 * time in milliseconds
		 * @param	p_delay
		 * @return
		 */
		public function addDelay( p_delay:uint ):int
		{
			_sequenceArray.push( p_delay );
			resetTotalTime();
			return _totalTime;
		}
		
		/**
		 * call this when you are ready for the sequence to play
		 * @return
		 */
		public function playSequence():Number
		{
			_totalTime = 0;
			
			resetTotalTime();
			
			_startTime = getTimer();
			
			handleNextItemInSequence( _sequenceArray );
			
			return _totalTime;
		}
		
		/**
		 * this will stop and clear out this sequence, prepping it for garbage collection.
		 * @return
		 */
		public function stopSequence():void
		{
			if (_sequenceArray.length)
			{
				var currentItem:Object = _sequenceArray[0];
				
				if ( currentItem is String )
				{
					SoundManager.getInstance().stopSound( currentItem as String );
				}
				
				if (_sequenceTimer.running)
				{
					_sequenceTimer.stop();
					_sequenceTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, sequenceTimerComplete);
				}
				
				_sequenceArray = new Array();
			}
		}
		
		public function pauseSequence():void
		{
			if (_sequenceArray.length)
			{
				var currentItem:Object = _sequenceArray[0];
				
				if ( currentItem is String )
				{
					SoundManager.getInstance().pauseSound( currentItem as String );
				}
				
				if (_sequenceTimer.running)
				{
					_sequenceTimer.pause();
				}
			}
		}
		
		public function resumeSequence():void
		{
			if (_sequenceArray.length && _sequenceTimer.paused)
			{
				var currentItem:Object = _sequenceArray[0];
				
				if ( currentItem is String )
				{
					SoundManager.getInstance().playSound( currentItem as String );
				}
				
				_sequenceTimer.resume();
			}
		}
		
		private function handleNextItemInSequence(p_sequence:Array):void
		{
			if ( !p_sequence.length )
			{
				dispatchEvent( new Event(Event.COMPLETE) );
			}
			else
			{
				var currentItem:Object = _sequenceArray[0];
				
				if (currentItem is Number)
				{
					_sequenceTimer = new PauseTimer(uint(currentItem), 1);
					_sequenceTimer.addEventListener(TimerEvent.TIMER_COMPLETE, sequenceTimerComplete);
					_sequenceTimer.start();
				}
				else if (currentItem is String)
				{
					
					_sequenceTimer = new PauseTimer(SoundManager.getInstance().getSoundDuration(currentItem as String), 1);
					
					_sequenceTimer.addEventListener(TimerEvent.TIMER_COMPLETE, sequenceTimerComplete);
					_sequenceTimer.start();
					SoundManager.getInstance().playSound(currentItem as String);
					
				}
			}
			
		}
		
		private function sequenceTimerComplete(e:TimerEvent):void
		{
			e.currentTarget.removeEventListener(TimerEvent.TIMER_COMPLETE, sequenceTimerComplete);
			
			var currentItem:Object = _sequenceArray.shift();
		
			handleNextItemInSequence( _sequenceArray );
		}
		
		private function resetTotalTime():void
		{
			_totalTime = 0;
			var i:int = 0;
			for ( i = 0; i < _sequenceArray.length; i++)
			{
				if ( _sequenceArray[i] is Number )
				{
					_totalTime += uint(_sequenceArray[i]);
				}
				else if ( _sequenceArray[i] is String )
				{
					_totalTime += SoundManager.getInstance().getSoundDuration( _sequenceArray[i] as String );
				}
				//trace('total time inc: ' + _totalTime);
			}
		}
	}
}