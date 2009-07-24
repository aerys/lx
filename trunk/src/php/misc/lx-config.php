<?php

define('LX_NAMESPACE', 'http://lx.aerys.in');

if (!defined('LX_ROOT'))
  define('LX_ROOT', realpath(dirname(__FILE__) . '/../../..'));

if (!defined('LX_DEBUG'))
  define('LX_DEBUG', false);

if (!defined('LX_TIMEZONE'))
  define('LX_TIMEZONE', 'Europe/Paris');

if (!defined('LX_DOCUMENT_ROOT'))
  define('LX_DOCUMENT_ROOT', '/');

if (!defined('LX_DEFAULT_OUTPUT'))
  define('LX_DEFAULT_OUTPUT', 'xsl');

date_default_timezone_set(LX_TIMEZONE);

define('LX_SRC',	LX_ROOT . '/src/php');
define('LX_SCRIPTS',	LX_ROOT . '/scripts');
define('LX_XSL',	LX_ROOT . '/src/xsl');

require_once (LX_SRC . '/misc/lx-header.php');
require_once (LX_SRC . '/misc/lx-autoload.php');
require_once (LX_SRC . '/misc/lx-errors.php');

$_LX['DATABASES']	= array();
$_LX['CONTROLERS']	= array();

?>