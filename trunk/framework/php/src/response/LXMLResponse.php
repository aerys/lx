<?php

class LXMLResponse extends XMLResponse
{
  public function LXMLResponse()
  {
    parent::XMLResponse();
  }

  protected function httpHeader()
  {
    parent::httpHeader();

    header('Content-type: text/html; charset="utf-8"');
  }

  public function send()
  {
    $this->finalize();

    $dir = LX_APPLICATION_ROOT . '/src/views/' . $this->view . '/';
    $file = 'templates/' . $this->template . '.xsl';

    if (!file_exists($dir .'/' . $file))
	$file = 'lx-view.xsl';

    $xml = new DOMDocument();
    $xml->loadXML($this->document->saveXML());

    $xsl = new DOMDocument();
    $xsl->load($dir . $file);

    $processor = new XSLTProcessor();
    $processor->importStyleSheet($xsl);

    $result = $processor->transformToDoc($xml);

    echo $result->saveHTML();
  }
}

?>