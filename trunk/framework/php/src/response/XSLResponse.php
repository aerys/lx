<?php

class XSLResponse extends XMLResponse
{
  protected function finalize()
  {
    $dir = (LX_DOCUMENT_ROOT != '/' ? LX_DOCUMENT_ROOT . '/' : '/')
      . 'views/' . $this->view;
    $file = '/templates/' . $this->template . '.xsl';

    if (!file_exists(LX_APPLICATION_ROOT . '/src/views/' . $this->view .'/' . $file))
	$file = '/lx-view.xsl';

    $pAttr = 'type="text/xsl" href="' . $dir . $file . '"';
    $xslNode = $this->document->createProcessingInstruction('xml-stylesheet',
							    $pAttr);

    $this->document->insertBefore($xslNode, $this->rootNode);

    parent::finalize();
  }

}

?>