<?php

require_once ('../misc/lx-bootstrap.php');
require_once ('../misc/lx-configure.php');

$xml = new DOMDocument();
$xml->load($argv[1]);

$xsl = new DOMDocument();
$xsl->load(LX_XSL . '/project/lx-project-php.xsl');

$processor = new XSLTProcessor();
$processor->importStyleSheet($xsl);
$processor->transformToURI($xml, 'php://output');

?>