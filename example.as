package
{	
	import com.pusherPipe.PusherPipe;
	import com.pusherPipe.events.PusherPipeChannelEvent;
	import com.pusherPipe.events.PusherPipeEvent;
	import com.pusherPipe.events.PusherPipeSocketEvent;
	
	import flash.display.Sprite;
	
	public class Main extends Sprite
	{
		public var pipe:PusherPipe;
		
		public function Main()
		{	
			//Create new pipe
			pipe = new PusherPipe('your_key', 'your_secret', your_app_id); //Key, secret, app_id
			
			//Subscribe to socket events
			pipe.subscribe(['socket_message','socket_existence']);
			
			//Listen when pipe and new sockets connect
			pipe.addEventListener(PusherPipeEvent.PIPE_CONNECTED, pipeConnected);
			pipe.addEventListener(PusherPipeSocketEvent.SOCKET_OPENED, socketConnected);
			pipe.addEventListener(PusherPipeSocketEvent.SOCKET_CLOSED, socketDisconnected);
			
			//Listen for 'someChannelEvent' on channel 'someChannel'
			pipe.channelWithName('someChannel').addEventListener('someChannelEvent', someChannelEvent);
			
			pipe.connect();
		}
		
		public function pipeConnected(e:PusherPipeEvent):void {
			trace("Pipe connected");
		}
		
		public function socketConnected(e:PusherPipeSocketEvent):void {
			e.socket.addEventListener('someSocketEvent',someSocketEvent);
			trace("Socket connected");
		}
		
		public function socketDisconnected(e:PusherPipeSocketEvent):void {
			trace("Socket disconnected");
		}
		
		public function someSocketEvent(e:PusherPipeSocketEvent):void {
			trace("Received socket event. id: " + e.socket.socketId + " - event: " + e.type + " - data: " + e.data);
		}
		
		public function someChannelEvent(e:PusherPipeChannelEvent):void {
			trace("Received channel event. id: " + e.socket.socketId + " - event: " + e.type + " - data: " + e.data);
		}
	}
}
