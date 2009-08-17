<?php

class XMLResponse
{
  protected $document	= NULL;
  protected $rootNode	= NULL;

  protected $view	= 'default';
  protected $layout	= 'index';
  protected $template	= 'default';

  protected $start_time	= 0;

  public function setView($my_view)	{$this->view = $my_view;}
  public function setLayout($my_layout)	{$this->layout = $my_layout;}
  public function setTemplate($my_temp)	{$this->template = $my_temp;}

  public function getDocument()		{return ($this->document);}
  public function getView()		{return ($this->view);}
  public function getLayout()		{return ($this->layout);}
  public function getTemplate()		{return ($this->template);}

  public function XMLResponse()
  {
    $this->start_time = microtime();

    $this->document = new DOMDocument('1.0', 'utf-8');

    $this->rootNode = $this->document->createElement('lx:response');
    $this->rootNode->setAttribute('xmlns:lx', LX_NAMESPACE);
    $this->rootNode->setAttribute('host', $_SERVER['HTTP_HOST']);
    $this->rootNode->setAttribute('date', time());
    $this->rootNode->setAttribute('document-root', LX_DOCUMENT_ROOT);

    $this->document->appendChild($this->rootNode);
  }

  public function appendController($my_controller, $my_name, $my_action)
  {
    $node = LX::getResponse()->getDocument()->createElement('lx:controller');
    $fragment = $my_controller->getFragment();

    $node->setAttribute('name', $my_name);
    $node->setAttribute('action', $my_action);

    if (LX_MODULE)
      $node->setAttribute('module', LX_MODULE);

    if ($fragment->hasAttributes() || $fragment->hasChildNodes())
      $node->appendChild($fragment);

    $this->rootNode->appendChild($node);
  }

  public function appendErrorException($my_exception)
  {
    $node = $this->document->createElement('lx:error');
    $node->setAttribute('type', get_class($my_exception));

    $trace_node = $this->document->createElement('trace');
    $trace_node->nodeValue = $my_exception->getTraceAsString();

    $message = $this->document->createElement('message');
    $message->nodeValue = $my_exception->getMessage();

    $node->appendChild($message);
    $node->appendChild($trace_node);

    $this->rootNode->appendChild($node);
  }

  public function appendException($my_exception)
  {
    $node = $this->document->createElement('lx:exception');
    $node->setAttribute('type', get_class($my_exception));

    $node->nodeValue = $my_exception->getMessage();

    $this->rootNode->appendChild($node);
  }

  public function appendFilter($my_filter, $my_name)
  {
    $node = $this->document->createElement('lx:filter');
    $fragment = $my_filter->getFragment();

    $node->setAttribute('name', $my_name);
    if ($fragment->hasAttributes() || $fragment->hasChildNodes())
      $node->appendChild($fragment);

    $this->rootNode->appendChild($node);
  }

  protected function finalize()
  {
    // update the root node
    $this->rootNode->setAttribute('time', abs(microtime() - $this->start_time) * 1000);

    // insert view node
    $viewCfg = $this->document->createElement('lx:view');
    $viewCfg->setAttribute('name', $this->view);
    $viewCfg->setAttribute('layout', $this->layout);
    $viewCfg->setAttribute('template', $this->template);
    $this->rootNode->insertBefore($viewCfg, $this->rootNode->firstChild);
  }

  public function save($my_filename	= NULL)
  {
    $this->finalize();

    if ($my_filename != NULL)
      return ($this->document->saveXML($my_filename));

    header('Content-type: text/xml; charset="utf-8"');

    return ($this->document->saveXML());
  }

}

?>