package aerys.lx 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Proxy;
	import flash.utils.escapeMultiByte;
	import flash.utils.flash_proxy;
	
	/**
	 * ...
	 * @author Jean-Marc Le Roux
	 */
	dynamic public class LXController extends Proxy implements IEventDispatcher
	{
		private var _url		: String			= null;
		private var _dispatcher	: EventDispatcher	= new EventDispatcher();
		
		public function LXController(myURL : String) 
		{
			super();
			
			_url = myURL;
		}
		
		override flash_proxy function callProperty(name : *, ...rest) : *
		{
			var url : String = _url + "/" + name;
			var numArguments : int = rest.length;
			var request : URLRequest = new URLRequest();
			var loader : URLLoader = new URLLoader();
			var data : URLVariables = new URLVariables();
			
			if (rest[numArguments - 1] is Function)
			{
				var callback : Function = rest[rest.length - 1] as Function;
				
				--numArguments;
				
				addEventListener(LXEvent.RESPONSE, function(e : LXEvent) : void
				{
					callback.call(null, e.response);
				});
			}
			
			if (typeof rest[0] == "object")
			{
				
				var obj : Object = rest[0];
				
				for (var propertyName : String in obj)
					data[propertyName] = obj[propertyName];
				
				request.method = URLRequestMethod.POST;
				
			}
			else
			{
				for (var i : int = 0; i < numArguments; ++i)
					url += "/" + escapeMultiByte(rest[i]);
			}
			
			data[int(Math.random() * int.MAX_VALUE).toString()] = int(Math.random() * int.MAX_VALUE);
			
			request.url = url + ".xml";
			request.data = data;
						
			loader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			loader.load(request);
			
			return new LXAction(request, this);
		}
		
		private function loaderCompleteHandler(e : Event) : void 
		{
			dispatchEvent(new LXEvent(LXEvent.RESPONSE, new XML((e.target as URLLoader).data)));
		}
		
		public function toString() : String
		{
			return _url;
		}
		
		public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void
		{
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public function dispatchEvent(event : Event) : Boolean
		{
			return _dispatcher.dispatchEvent(event);
		}

		public function hasEventListener(type : String) : Boolean
		{
			return _dispatcher.hasEventListener(type);
		}

		public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void
		{
			_dispatcher.removeEventListener(type, listener, useCapture);
		}

		public function willTrigger(type : String) : Boolean
		{
			return _dispatcher.willTrigger(type);
		}
	}

}