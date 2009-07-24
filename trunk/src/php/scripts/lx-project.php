<?php

require_once ('../misc/lx-config.php');


$xml = new DOMDocument();
$xml->load($argv[1]);

$xsl = new DOMDocument();
$xsl->load(LX_XSL . '/lx-project.xsl');

$processor = new XSLTProcessor();
$processor->importStyleSheet($xsl);
$processor->transformToURI($xml, 'php://output');

?>