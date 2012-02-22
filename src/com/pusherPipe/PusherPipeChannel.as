package com.pusherPipe
{
	import flash.events.EventDispatcher;

	public class PusherPipeChannel extends EventDispatcher
	{
		public var pipeClient:PusherPipe;
		public var name:String;
		
		public function PusherPipeChannel(pipe:PusherPipe, name:String)
		{
			this.pipeClient = pipe;
			this.name = name;
		}
		
		public function trigger(event:String, data:Object, socketId:String = null):void {
			this.pipeClient._sendRequest('send_to_channel', {
				channel: this.name,
				event: event,
				data: data,
				socketId: socketId
			});
		}
	}
}