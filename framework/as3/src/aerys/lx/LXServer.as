package aerys.lx 
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	/**
	 * ...
	 * @author Jean-Marc Le Roux
	 */

	dynamic public class LXServer extends Proxy
	{
		private var _url	: String	= null;
		private var _extra	: Object	= null;
		
		public function get url() : String
		{
			return _url;
		}
		
		public function LXServer(myURL : String = "", myExtra : Object = null)
		{
			super();
			
			_url = myURL;
			_extra = myExtra;
		}
		
		override flash_proxy function getDescendants(name : * ) : *
		{
			return new LXModule(_url + "/" + name, _extra);
		}
		
		override flash_proxy function getProperty(name : *) : *
		{
			return new LXController(_url + "/" + name, _extra);
		}
		
		public function toString() : String
		{
			return _url;
		}
	}

}