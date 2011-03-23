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
		
		public function get url() : String
		{
			return _url;
		}
		
		public function LXServer(myURL : String = "")
		{
			super();
			
			_url = myURL;
		}
		
		override flash_proxy function getDescendants(name : * ) : *
		{
			return new LXModule(_url + "/" + name);
		}
		
		override flash_proxy function getProperty(name : *) : *
		{
			return new LXController(_url + "/" + name);
		}
		
		public function toString() : String
		{
			return _url;
		}
	}

}