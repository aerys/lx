<?php

class FacebookFilter extends AbstractFilter
{
	private $facebook	= null;
	private $session 	= null;
	private $infos 		= null;

	public function getFacebookAPI()  	{ return $this->facebook; }
	public function getSession()		{ return $this->session; }
	public function getInfos()			{ return $this->infos; }

	public function filter($parameters)
	{
		require_once('facebook/src/facebook.php');

		header('P3P:CP="IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT"');

		$this->facebook = new Facebook(array('appId'  => FB_APP_ID,
                                         	 'secret' => FB_SECRET_KEY,
                                         	 'cookie' => true));

		$this->session = $this->facebook->getSession();
		$this->signedRequest = $this->facebook->getSignedRequest();
		
		if ($this->signedRequest && isset($this->signedRequest['page']))
		{
			$this->page = $this->signedRequest['page'];
			echo XML::serialize(array('page' => array('@id' 	=> $this->page['id'],
													  '@liked'	=> $this->page['liked'] ? 'true' : 'false')));
		}
		
		if (defined('FB_REQUIRE_LIKE') && FB_REQUIRE_LIKE
		    && $this->page && FB_REQUIRE_LIKE == $this->page['id']
			&& !$this->isFan())
		{
			LX::setTemplate('facebook_like');
			
			throw new FilterException($this,
									  'You must like this page.');
		}
		
		if (!$this->session && FB_REQUIRE_LOGIN)
		{
			$url = $this->facebook->getLoginURL(array('canvas'      => 0,
                                                	  'fbconnect'   => 0,
                                                	  'req_perms'   => FB_PERMISSIONS));

			LX::setTemplate('facebook_login');
			
			throw new FilterException($this,
									  'You must be logged into Facebook.',
									  array('loginUrl'	=> $url,
						 			  		'id' 		=> FB_APP_ID,
					 	 			  		'url' 		=> FB_APP_URL));
		}
		
		define('FB_USER_ID', $this->session['uid']);
		
		return array('uid' 	=> FB_USER_ID,
					 'id' 	=> FB_APP_ID,
					 'url' 	=> FB_APP_URL);
	}

	public function isFan()
	{
		return $this->infos &&
			   array_key_exists('page', $this->infos) &&
			   $this->infos['page']['liked'];
	}
}

?>
