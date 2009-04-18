<?php

$xml = new DOMDocument();
$xml->load($argv[1]);

$xsl = new DOMDocument();
$xsl->load('./xsl/lx-project.xsl');

$processor = new XSLTProcessor();
$processor->importStyleSheet($xsl);
$processor->transformToURI($xml, 'php://output');

?>