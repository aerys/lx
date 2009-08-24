<?php

class HTMLResponse extends XMLResponse
{
  public function HTMLResponse()
  {
    parent::XMLResponse();

    header('Content-type: text/html; charset="utf-8"');
  }

  public function save($my_filename	 = NULL)
  {
    $xml_text = parent::save($my_filename);

    $xml = new DOMDocument();
    $xml->loadXML($xml_text);

    $xsl = new DOMDocument();
    $xsl->load(LX_APPLICATION_ROOT . '/src/views/' . $this->view
	       . '/templates/' . $this->template . '.xsl');

    $processor = new XSLTProcessor();
    $processor->importStyleSheet($xsl);

    $result = $processor->transformToDoc($xml);

    $result->save(LX_APPLICATION_ROOT . '/tmp/test.html');

    return ($result->saveHTML());
  }
}

?>