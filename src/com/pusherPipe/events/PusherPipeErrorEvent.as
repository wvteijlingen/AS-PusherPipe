package com.pusherPipe.events
{
	import com.pusherPipe.PusherPipe;
	
	import flash.events.Event;

	public class PusherPipeErrorEvent extends Event
	{	
		public var pipe:PusherPipe;
		public var error:Error;
		
		public function PusherPipeErrorEvent(type:String, pipe:PusherPipe, error:Error, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.pipe = pipe;
			this.error = error;
		}
		
		override public function clone():Event {
			return new PusherPipeErrorEvent(this.type, this.pipe, this.error, super.bubbles, super.cancelable);
		}
	}
}