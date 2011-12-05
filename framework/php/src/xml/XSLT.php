<?php

class XSLT
{
	const XSL_NAMESPACE	= 'http://www.w3.org/1999/XSL/Transform';
	
	private $processor = null;
	
	public function XSLT()
	{
		$this->processor = new XSLTProcessor();
	}
	
	public function import($xslDocument)
	{
		$this->startXMLErrors();
		$this->processor->importStyleSheet($xslDocument);
		$this->handleXMLErrors();
	}
	
	public function addInclude($uri)
	{
		$root = $xsl->getElementsByTagName('include')->item(0);
		$uri = str_replace('\\', '/', $uri);
					
		$node = $xsl->createElementNS(XSLT::XSL_NAMESPACE, 'xsl:include');
		$node->setAttribute('href', $uri);
			
		$root->parentNode->insertBefore($node, $root);
	}
	
	public function transformToUri($xmlDocument, $output)
	{
		$this->startXMLErrors();
		$this->processor->transformToURI($xmlDocument, $output);
		$this->handleXMLErrors();
	}
	
	public function transformToDoc($xmlDocument)
	{
		$this->startXMLErrors();
		$result = $this->processor->transformToDoc($xmlDocument);
		$this->handleXMLErrors();
		
		return $result;
	}
	
	private function startXMLErrors()
	{
		libxml_use_internal_errors(true);
	}
	
	private function handleXMLErrors()
	{
	 	$xslErrors = libxml_get_errors();
	 	$msg = 'XSLT errors: ';
	 	if (count($xslErrors))
	 	{
	 		foreach ($xslErrors as $i => $error)
	 		{
		 		if ($i != 0)
		 			$msg .= ', ';
		 		$msg .= trim($error->message);
	 		}
	 		
	 		throw new ErrorException($msg);
	 	}
	 	
	 	
	 	libxml_use_internal_errors(false);
	}
}