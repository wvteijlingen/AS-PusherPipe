package com.pusherPipe.events
{
	import com.pusherPipe.PusherPipe;
	import com.pusherPipe.PusherPipeSocket;
	
	import flash.events.Event;

	public class PusherPipeEvent extends Event
	{
		static public const PIPE_CONNECTED:String = "connected";
		static public const PIPE_DISCONNECTED:String = "disconnected";
		static public const PIPE_SUBSCRIBED:String = "subscribed";
		
		public var pipe:PusherPipe;
		
		public function PusherPipeEvent(type:String, pipe:PusherPipe, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.pipe = pipe;
		}
		
		override public function clone():Event {
			return new PusherPipeEvent(this.type, this.pipe, super.bubbles, super.cancelable);
		}
	}
}