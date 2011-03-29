<?php

// constants definition
define('LX_CLIENT_XSL_SUPPORT', isset($_COOKIE['LX_CLIENT_XSL_SUPPORT'])
                                ? !!$_COOKIE['LX_CLIENT_XSL_SUPPORT']
                                : null);

define('LX_NAMESPACE',		'http://lx.aerys.in');
define('LX_DEFAULT_TIMEZONE',	'Europe/Paris');
define('LX_DEFAULT_HTTP_CACHE',  3600 * 24 * 365);

if (!defined('LX_ROOT'))
  define('LX_ROOT', realpath(dirname(__FILE__) . '/../../..'));

if (!defined('LX_APPLICATION_ROOT'))
  define('LX_APPLICATION_ROOT', realpath('..'));

if (!defined('LX_DEFAULT_VIEW'))
  define('LX_DEFAULT_VIEW', 'default');

if (!defined('LX_DEFAULT_LAYOUT'))
  define('LX_DEFAULT_LAYOUT', 'default');

if (!defined('LX_DEFAULT_TEMPLATE'))
  define('LX_DEFAULT_TEMPLATE', 'default');

if (!defined('LX_DEBUG'))
  define('LX_DEBUG', false);

if (!defined('LX_HTTP_CACHE'))
  define('LX_HTTP_CACHE', LX_DEFAULT_HTTP_CACHE);

define('LX_HOST', isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : null);

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

set_include_path(get_include_path()
                 . PATH_SEPARATOR . LX_APPLICATION_ROOT
                 . PATH_SEPARATOR . LX_APPLICATION_ROOT . '/lib');

function __autoload($class_name)
{
  LX::autoload($class_name);
}

function lx_error_handler($errno,
			  $errstr,
			  $errfile,
			  $errline,
			  $context)
{
  throw new ErrorException($errstr, 0, $errno, $errfile, $errline);

  /* Don't execute PHP internal error handler */
  return true;
}

set_error_handler('lx_error_handler');
if (LX_DEBUG)
  error_reporting(0xffffffff);

?>