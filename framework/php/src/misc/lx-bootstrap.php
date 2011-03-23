<?php

// XSL activation
if (isset($_REQUEST['LX_DISABLE_CLIENT_XSL_SUPPORT']))
{
  setcookie('LX_XSL_SUPPORT', false, time() + 31536000);
  exit ;
}
if (isset($_REQUEST['LX_ENABLE_CLIENT_XSL_SUPPORT']))
{
  setcookie('LX_CLIENT_XSL_SUPPORT', true, time() + 31536000);
  exit ;
}

define('LX_DEFAULT_MODULE',     'default');
define('LX_DEFAULT_CONTROLLER', 'default');
define('LX_DEFAULT_EXTENSION',	'default');

$_LX['databases'] = array();
$_LX['map'] = array('filters'		=> array(),
		    'modules'		=> array(),
		    'controllers'	=> array());

?>