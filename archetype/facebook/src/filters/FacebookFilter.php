<?php

class FacebookFilter extends AbstractFilter
{
  private $facebook	= null;
  private $session 	= null;
  private $infos 	= null;

  public function getFacebookAPI()      { return $this->facebook; }
  public function getSession()		{ return $this->session; }
  public function getInfos()		{ return $this->infos; }

  public function filter()
  {
    require_once('facebook/src/facebook.php');

    header('P3P:CP="IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT"');

    $this->facebook = new Facebook(array('appId'  => FB_APP_ID,
                                         'secret' => FB_SECRET_KEY,
                                         'cookie' => true));

    $this->session = $this->facebook->getSession();
    $this->infos = $this->facebook->getSignedRequest();

    if (!$this->session)
    {
      $url = $this->facebook->getLoginURL(array('canvas'      => 0,
                                                'fbconnect'   => 0,
                                                'req_perms'   => FB_PERMISSIONS));


      /* if (LX_DEBUG && LX::getResponse() instanceof XMLResponse) */
      /* { */
      /*   LX::redirect($url); */
      /* } */

      LX::setTemplate('facebook_login');
      echo XML::node('login', $url);

      throw new FilterException($this, 'You must be logged into Facebook.');
    }

    define('FB_USER_ID', $this->session['uid']);
    echo '<uid>' . $this->session['uid'] . '</uid>';
    echo '<id>' . FB_APP_ID . '</id>';
    echo '<url>' . FB_APP_URL . '</url>';
  }

  public function isFan()
  {
    return
      $this->infos &&
      array_key_exists('page', $this->infos) &&
      $this->infos['page']['liked'];
  }
}

?>
