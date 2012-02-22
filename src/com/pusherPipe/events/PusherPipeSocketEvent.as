package com.pusherPipe.events
{
	import com.pusherPipe.PusherPipeSocket;
	
	import flash.events.Event;

	public class PusherPipeSocketEvent extends Event
	{
		static public const SOCKET_OPENED:String = "socketOpened";
		static public const SOCKET_CLOSED:String = "socketClosed";
		
		public var socket:PusherPipeSocket;
		public var data:Object;
		
		public function PusherPipeSocketEvent(type:String, socket:PusherPipeSocket = null, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.socket = socket;
			this.data = data;
		}
		
		override public function clone():Event {
			return new PusherPipeSocketEvent(this.type, this.socket, this.data, super.bubbles, super.cancelable);
		}
	}
}