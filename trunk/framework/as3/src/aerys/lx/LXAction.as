package aerys.lx
{
	import flash.net.URLRequest;

	public final class LXAction
	{
		private var _complete	: Array			= new Array();
		private var _parameters	: Array			= new Array();
		private var _request	: URLRequest	= null;
		
		public function get request() : URLRequest	{ return _request; }
		
		public function LXAction(myRequest : URLRequest, myController : LXController)
		{
			_request = myRequest;
			
			myController.addEventListener(LXEvent.RESPONSE, responseHandler);
		}
		
		private function responseHandler(event : LXEvent) : void
		{
			var numCallbacks : int = _complete.length;
			var parameters : Array = new Array();
			var response : XML = event.response;
			
			for (var i : int = 0; i < numCallbacks; ++i)
			{
				var numParams : int = _parameters[i].length;
				
				parameters.length = 0;
				for (var j : int = 0; j < numParams; ++j)
				{
					var param : * = _parameters[i][j];
					var xml : XML =  param as XML;
					
					parameters[j] = xml != null ? response.descendants(xml.name())
												: param;
				}
				
				(_complete[i] as Function).apply(null, parameters);
			}
		}
		
		public function onComplete(myCallback : Function,
								   ...parameters) : LXAction
		{
			_complete.push(myCallback);
			_parameters.push(parameters);
			
			return this;
		}
	}
}