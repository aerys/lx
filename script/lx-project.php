<?php

define('LX_HOME', getenv('LX_HOME'));
require_once (LX_HOME . '/framework/php/src/misc/lx-bootstrap.php');
require_once (LX_HOME . '/framework/php/src/misc/lx-configure.php');

$xml = new DOMDocument();
$xml->load($argv[1]);

//$format = isset($argv[2]) && in_array($argv[2], array('php', 'xsl')) ? $argv[2] : 'php';

$xsl = new DOMDocument();
//$xsl->load(LX_XSL . '/project/lx-project-' . $format . '.xsl');
$xsl->load(LX_XSL . '/project/lx-project-php.xsl');

$processor = new XSLTProcessor();
$processor->importStyleSheet($xsl);

if (isset($argv[2]))
   $processor->setParameter('', 'LX_CONFIGURATION_NAME', $argv[2]);

$processor->transformToURI($xml, 'php://output');

?>