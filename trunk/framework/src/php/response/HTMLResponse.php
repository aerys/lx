<?php

class HTMLResponse extends XMLResponse
{
  public function HTMLResponse()
  {
    parent::XMLResponse();
  }

  public function save($my_filename	 = NULL)
  {
    $dir = LX_APPLICATION_ROOT . '/src/views/' . $this->view . '/';
    $file = 'templates/' . $this->template . '.xsl';

    if (!file_exists($dir .'/' . $file))
	$file = 'lx-view.xsl';

    $xml_text = parent::save($my_filename);

    $xml = new DOMDocument();
    $xml->loadXML($xml_text);

    $xsl = new DOMDocument();
    $xsl->load($dir . $file);

    $processor = new XSLTProcessor();
    $processor->importStyleSheet($xsl);

    $result = $processor->transformToDoc($xml);

    //$result->save(LX_APPLICATION_ROOT . '/tmp/test.html');

    header('Content-type: text/html; charset="utf-8"');

    return ($result->saveHTML());
  }
}

?>