package com.pusherPipe.events
{
	import flash.events.Event;

	public class SocketEvent extends Event
	{
		public var eventName:String;
		public var socketId:String;
		public var data:Object;
		
		public function SocketEvent(eventName:String, socketId:String, data:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.eventName = eventName;
			this.socketId = socketId;
			this.data = data;
		}
		
		override public function clone():Event {
			return new SocketEvent(this.eventName, this.socketId, this.data, super.bubbles, super.cancelable);
		}
	}
}