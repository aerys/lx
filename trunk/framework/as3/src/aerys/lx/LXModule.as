package aerys.lx 
{
	import flash.utils.flash_proxy;
	import flash.utils.Proxy;
	
	/**
	 * ...
	 * @author Jean-Marc Le Roux
	 */
	dynamic public class LXModule extends Proxy
	{
		private var _url	: String	= null;
		
		public function LXModule(myURL : String) 
		{
			super();
			
			_url = myURL;
		}
		
		override flash_proxy function getProperty (name:*) : *
		{
			return new LXController(_url + "/" + name);
		}
		
		public function toString() : String
		{
			return _url;
		}
		
	}

}