package com.pusherPipe.events
{
	import com.pusherPipe.PusherPipeChannel;
	import com.pusherPipe.PusherPipeSocket;
	
	import flash.events.Event;

	public class PusherPipeChannelEvent extends Event
	{	
		public var socket:PusherPipeSocket;
		public var channel:PusherPipeChannel;
		public var data:Object;
		
		public function PusherPipeChannelEvent(type:String, socket:PusherPipeSocket, channel:PusherPipeChannel, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.socket = socket;
			this.channel = channel;
			this.data = data;
		}
		
		override public function clone():Event {
			return new PusherPipeChannelEvent(this.type, this.socket, this.channel, this.data, super.bubbles, super.cancelable);
		}
	}
}