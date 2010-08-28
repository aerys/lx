<?php

define('LX_NAMESPACE',		'http://lx.aerys.in');
define('LX_DEFAULT_TIMEZONE',	'Europe/Paris');
define('LX_DEFAULT_EXTENSION',	'');

if (!defined('LX_DEFAULT_MODULE'))
  define('LX_DEFAULT_MODULE', 'default');

if (!defined('LX_DEFAULT_CONTROLLER'))
  define('LX_DEFAULT_CONTROLLER', 'default');

if (!defined('LX_DEFAULT_VIEW'))
  define('LX_DEFAULT_VIEW', 'default');

if (!defined('LX_DEFAULT_LAYOUT'))
  define('LX_DEFAULT_LAYOUT', 'default');

if (!defined('LX_DEFAULT_TEMPLATE'))
  define('LX_DEFAULT_TEMPLATE', 'default');

if (!defined('LX_DEBUG'))
  define('LX_DEBUG', false);

if (LX_DEBUG)
  error_reporting(E_ALL);

if (!defined('LX_TIMEZONE'))
  define('LX_TIMEZONE', LX_DEFAULT_TIMEZONE);
date_default_timezone_set(LX_TIMEZONE);

if (!defined('LX_DOCUMENT_ROOT'))
  define('LX_DOCUMENT_ROOT', '/');

define('LX_SRC',	LX_ROOT . '/php/src');
define('LX_SCRIPTS',	LX_ROOT . '/scripts');
define('LX_XSL',	LX_ROOT . '/xsl/src');

require_once (LX_SRC . '/LX.php');

$_LX['databases'] = array();
$_LX['map'] = array('filters'		=> array(),
		    'modules'		=> array(),
		    'controllers'	=> array());

?>