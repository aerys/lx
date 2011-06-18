package aerys.lx 
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	/**
	 * ...
	 * @author Jean-Marc Le Roux
	 */
	dynamic public class LXModule extends Proxy
	{
		private var _url	: String	= null;
		private var _extra	: Object	= null;
		
		public function LXModule(myURL : String, myExtra : Object = null) 
		{
			super();
			
			_url = myURL;
			_extra = myExtra;
		}
		
		override flash_proxy function getProperty (name:*) : *
		{
			return new LXController(_url + "/" + name, _extra);
		}
		
		public function toString() : String
		{
			return _url;
		}
		
	}

}