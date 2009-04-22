<?php

if (!defined('LX_ROOT'))
  define('LX_ROOT', realpath('..'));

define('LX_SRC',	LX_ROOT . '/src');
define('LX_SCRIPTS',	LX_ROOT . '/scripts');
define('LX_XSL',	LX_ROOT . '/xsl');

require_once (LX_SRC . '/misc/lx-header.php');
require_once (LX_SRC . '/misc/lx-autoload.php');
require_once (LX_SRC . '/misc/lx-errors.php');

$_LX['DATABASES']	= array();
$_LX['CONTROLERS']	= array();

?>