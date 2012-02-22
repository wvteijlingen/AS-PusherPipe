package com.pusherPipe
{
	import com.adobe.utils.ArrayUtil;
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.hash.HMAC;
	import com.hurlant.util.Hex;
	import com.pusherPipe.events.PusherPipeChannelEvent;
	import com.pusherPipe.events.PusherPipeErrorEvent;
	import com.pusherPipe.events.PusherPipeEvent;
	import com.pusherPipe.events.PusherPipeSocketEvent;
	import com.pusherPipe.utils.JSONRPC;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	import com.worlize.websocket.WebSocketMessage;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import mx.utils.UIDUtil;
	
	public class PusherPipe extends EventDispatcher
	{
		private var _key:String;
		private var _secret:String;
		private var _appId:Number;
		
		private var _websocket:WebSocket;
		
		private var _connectedSockets:Array;
		private var _channels:Array;
		
		public var isConnected:Boolean;
		public var connectionId:String = null;
		public var subscriptions:Array;
		
		public function PusherPipe(key:String, secret:String, appId:Number)
		{
			this._key = key;
			this._secret = secret;
			this._appId = appId;
			
			this._connectedSockets = new Array();
			this._channels = new Array();
			this.subscriptions = new Array();
		}
		
		public function connect():void {
			var path:String = '/app/' + this._appId;
			var params:String = "auth_key=" + this._key + "&auth_timestamp=" + Math.floor(new Date().getTime() / 1000) + "&auth_version=1.0&protocol_version=0.2";
			
			var url:String = "ws://wsapi.darling.pusher.com:8080" + path + "?" + params + '&auth_signature=' + this._signature(path, params);	
			
			trace(url);
			
			this._websocket = new WebSocket(url, "*");
			this._websocket.addEventListener(WebSocketEvent.CLOSED, _handleWebSocketClosed);
			this._websocket.addEventListener(WebSocketEvent.OPEN, _handleWebSocketOpen);
			this._websocket.addEventListener(WebSocketEvent.MESSAGE, _handleWebSocketMessage);
			this._websocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, _handleConnectionFail);
			this._websocket.connect();
		}
		
		public function subscribe(events:Array):void {
			for (var i:int = 0; i < events.length; i++) 
			{
				var eventName:String = events[i];
				if(ArrayUtil.arrayContainsValue(this.subscriptions,eventName) == false) {
					this.subscriptions.push(eventName);
				}
			}
			
			if(this.isConnected) {
				this._sendRequest('subscribe',{'events':events});
			}
		}
		
		public function unsubscribe(events:Array):void {
			for (var i:int = 0; i < events.length; i++) 
			{
				var eventName:String = events[i];
				ArrayUtil.removeValueFromArray(this.subscriptions, eventName);
			}
			
			if(this.isConnected) {
				this._sendRequest('unsubscribe', {'events':events});
			}
		}
		
		public function channelWithName(name:String):PusherPipeChannel {
			if(!name in this._channels) {
				this._channels[name] = new PusherPipeChannel(this, name);
			}
			
			return this._channels[name];
		}
		
		public function socketWithId(id:String):PusherPipeSocket {
			if(id in this._connectedSockets) return this._connectedSockets[id];
			return null;
		}
		
		public function _sendRequest(method:String, params:Object):void {
			var id:String = UIDUtil.createUID();
			var request:String = JSONRPC.encodeRPCRequest(id,method, params);
			this._websocket.sendUTF(request);
		}
		
		private function _handleWebSocketOpen(event:WebSocketEvent):void {
			//trace("Connected");
		}
		
		private function _handleWebSocketClosed(event:WebSocketEvent):void {
			//trace("Disconnected");
		}
		
		private function _handleConnectionFail(event:WebSocketErrorEvent):void {
			trace("Connection Failure: " + event.text);
		}
		
		private function _handleWebSocketMessage(event:WebSocketEvent):void {
			if (event.message.type === WebSocketMessage.TYPE_UTF8) {
				//trace("Got message: " + event.message.utf8Data);
				
				var messageObject:Object = JSONRPC.decodeRPCResponse(event.message.utf8Data);
				if(messageObject.id !== null) {
					//handleReply();
				} else {
					this._handleNotification(messageObject);
				}
				
			}
			else if (event.message.type === WebSocketMessage.TYPE_BINARY) {
				trace("Discarding binary message of length " + event.message.binaryData.length);
			}
		}
		
		/**
		 * Bind an event for a socket event.
		 * @param eventName Event name to bind
		 * @param callback Callback to call
		 * @param socketId Optionally. If set, the event will be bound to every socket with this id (including future sockets).
		 */
		/*public function bindSocketEvent(eventName:String, callback:Function, socketId:Number = -1):void {
		if(socketId == -1) {
		this._callbacks[eventName] = this._callbacks[eventName] || [];
		this._callbacks[eventName].push(callback);
		} else {
		this._socketCallbacks[socketId][eventName] = this._socketCallbacks[socketId][eventName] || [];
		this._socketCallbacks[socketId][eventName].push(callback);
		}
		}
		
		public function unBindSocketEvent(eventName:String, callback:Function, socketId:Number = -1):void {
		//TODO: Implement
		}*/
		
		private function _handleNotification(notification:Object):void {
			var eventObject:Event;
			var socketId:String;
			
			if(notification.error === null) {
				// switch for notification types
				var type:String = notification.result.event;
				var payload:Object = notification.result.data;
				
				if(type === 'connection_established') {
					this.isConnected = true;
					
					eventObject = new PusherPipeEvent(PusherPipeEvent.PIPE_CONNECTED, this);
					this.dispatchEvent(eventObject);
					this.connectionId = payload.socket_id;
					
					//Send subscriptions
					this._sendRequest('subscribe',  {'events':this.subscriptions});
					
				} else if (type === 'socket_opened') {
					var socket:PusherPipeSocket = new PusherPipeSocket(this, payload.socket_id);
					this._connectedSockets[payload.socket_id] = socket;
					
					eventObject = new PusherPipeSocketEvent(PusherPipeSocketEvent.SOCKET_OPENED, socket);
					this.dispatchEvent(eventObject);
					
				} else if (type === 'socket_closed') {
					socket = this._connectedSockets[payload.socket_id];
					eventObject = new PusherPipeSocketEvent(PusherPipeSocketEvent.SOCKET_CLOSED, socket);
					this.dispatchEvent(eventObject);
					socket.dispatchEvent(eventObject);
					
					this._connectedSockets[payload.socket_id] = null
					
				} else if (type === 'socket_message') {
					socketId = payload.socket_id;
					var data:Object = payload.data;
					var event:String = payload.event;
					
					// If the event has a channel, this means that it originated
					// on a channel object, so it's an event on a channel.
					if (payload.hasOwnProperty('channel')) {
						var channel:PusherPipeChannel = this.channelWithName(payload.channel);
						
						eventObject = new PusherPipeChannelEvent(event, this._connectedSockets[socketId], channel, data);
						this.dispatchEvent(eventObject);
						
						// Send to the firehose of channel events:
						//client.channels.emit('event', event, channel_name, socket_id, data);
						//client.channels.emit('event:' + event, channel_name, socket_id, data);
						
						
						if (channel.name in this._channels) {
							var channel:PusherPipeChannel = this._channels[channel.name];
							channel.dispatchEvent(eventObject);
						}
					} else {
						//Prepare the event to dispatch
						eventObject = new PusherPipeSocketEvent(event, this._connectedSockets[socketId], data);
						
						this.dispatchEvent(eventObject);
						this._connectedSockets[socketId].dispatchEvent(eventObject);
					}
					
				} else if (type === 'warning') {
					trace('WARNING:', payload)
				} else {
					trace('Unknown notification type: ' + type);
					//trace('data: ' + JSON.stringify(notification));
				}
			} else {
				var error:Error = new Error(notification.error.message, notification.error.code);
				
				eventObject = new PusherPipeErrorEvent("error", this, error);
				this.dispatchEvent(eventObject);
			}
		}
		
		private function _signature(path:String, params:String):String {
			var hmac:HMAC = Crypto.getHMAC('hmac-sha256');
			var keyData:ByteArray = Hex.toArray(Hex.fromString(this._secret));
			
			var input:String = 'WEBSOCKET\n' + path + '\n' + params;
			var data:ByteArray = Hex.toArray(Hex.fromString(input));
			
			var currentResult:ByteArray = hmac.compute(keyData, data);
			var signature:String = Hex.fromArray(currentResult);
			
			return signature;
		}
	}
}


//{"id":"3a472b8d-4f93-488f-89cb-22c18ab86fbc","method":"subscribe","params":{"events":["socket_message","socket_existence"],"data":""}}
