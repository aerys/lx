<?php

class XSLResponse extends XMLResponse
{
  protected function finalize()
  {
    $xsl = (LX_DOCUMENT_ROOT != '/' ? LX_DOCUMENT_ROOT . '/' : '/')
      . 'views/' . $this->view . '/templates/' . $this->template . '.xsl';
    $pAttr = 'type="text/xsl" href="' . $xsl . '"';
    $xslNode = $this->document->createProcessingInstruction('xml-stylesheet',
							    $pAttr);


    $this->document->insertBefore($xslNode, $this->rootNode);

    parent::finalize();
  }

}