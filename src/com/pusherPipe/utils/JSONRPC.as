package com.pusherPipe.utils
{
	import com.adobe.serialization.json.JSON;

	public class JSONRPC
	{
		public function JSONRPC()
		{
		}
		
		public static function encodeRPCRequest(id:*, method:*, params:*):String {
			return JSON.encode({
				id: id,
				method: method,
				params: params || {}
			});
		}
		
		public static function decodeRPCResponse(data:String):Object {
			//TODO: Error handling in parsing
			var parsed:Object = JSON.decode(data);
			
			if (!parsed.hasOwnProperty('id')) {
				throw new Error('Missing required property: "id".');
			}
			
			if (!parsed.hasOwnProperty('error')) {
				throw new Error('Missing required property: "error".');
			}
			
			if (!parsed.hasOwnProperty('result')) {
				throw new Error('Missing required property: "result".');
			}
			
			return parsed;
		}
	}
}