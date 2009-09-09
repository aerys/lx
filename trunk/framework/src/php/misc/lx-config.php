<?php

define('LX_NAMESPACE',		'http://lx.aerys.in');

define('LX_OUTPUT_HTML',	'html');
define('LX_OUTPUT_XML',		'xml');
define('LX_OUTPUT_XSL',		'xsl');

define('LX_DEFAULT_TIMEZONE',	'Europe/Paris');

if (!defined('LX_ROOT'))
  define('LX_ROOT', realpath(dirname(__FILE__) . '/../../..'));

if (!defined('LX_APPLICATION_ROOT'))
  define('LX_APPLICATION_ROOT', realpath('..'));

if (!defined('LX_DEFAULT_MODULE'))
  define('LX_DEFAULT_MODULE', 'home');

if (!defined('LX_DEFAULT_CONTROLLER'))
  define('LX_DEFAULT_CONTROLLER', 'home');

if (!defined('LX_DEFAULT_VIEW'))
  define('LX_DEFAULT_VIEW', 'default');

if (!defined('LX_DEBUG'))
  define('LX_DEBUG', false);

if (!defined('LX_TIMEZONE'))
  define('LX_TIMEZONE', LX_DEFAULT_TIMEZONE);

if (!defined('LX_DOCUMENT_ROOT'))
  define('LX_DOCUMENT_ROOT', '/');

if (!defined('LX_DEFAULT_OUTPUT'))
  define('LX_DEFAULT_OUTPUT', LX_OUTPUT_XSL);

define('LX_SRC',	LX_ROOT . '/src/php');
define('LX_SCRIPTS',	LX_ROOT . '/scripts');
define('LX_XSL',	LX_ROOT . '/src/xsl');

require_once (LX_SRC . '/LX.php');
require_once (LX_SRC . '/misc/lx-header.php');
require_once (LX_SRC . '/misc/lx-autoload.php');
require_once (LX_SRC . '/misc/lx-errors.php');

$_LX['DATABASES']	= array();

?>