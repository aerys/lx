package aerys.lx 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Jean-Marc Le Roux
	 */
	public class LXEvent extends Event
	{
		public static const RESPONSE	: String	= "response";
		
		private var _response : XML	= null;
		
		public function get response() : XML { return _response; }
		
		public function set response(value : XML) : void 
		{
			_response = value;
		}
		
		public function LXEvent(myType : String, myResponse : XML = null)
		{
			super(myType);
			
			_response = myResponse;
		}
		
	}

}