package com.pusherPipe
{
	import flash.events.EventDispatcher;

	public class PusherPipeSocket extends EventDispatcher
	{
		public var pipeClient:PusherPipe;
		public var socketId:String;
		
		public var connected:Boolean;
		
		public function PusherPipeSocket(pipe:PusherPipe, socketId:String)
		{
			this.pipeClient = pipe;
			this.socketId = socketId;
			this.connected = true;
		}
		
		public function trigger(event:String, data:Object):void {
			this.pipeClient._sendRequest('send_to_socket', {
				socket_id: this.socketId,
				event: event,
				data: data
			});
		}
	}
}