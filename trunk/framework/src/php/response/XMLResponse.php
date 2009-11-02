<?php

class XMLResponse
{
  protected $document		= NULL;
  protected $rootNode		= NULL;
  protected $requestNode	= NULL;
  protected $argumentNode	= NULL;

  protected $view		= LX_DEFAULT_VIEW;
  protected $layout		= 'index';
  protected $template		= 'default';

  protected $start_time		= 0;

  public function setView($my_view)		{$this->view = $my_view;}
  public function setLayout($my_layout)		{$this->layout = $my_layout;}
  public function setTemplate($my_temp)		{$this->template = $my_temp;}

  public function getDocument()		{return ($this->document);}
  public function getView()		{return ($this->view);}
  public function getLayout()		{return ($this->layout);}
  public function getTemplate()		{return ($this->template);}

  public function XMLResponse()
  {
    $this->start_time = microtime();

    $this->document = new DOMDocument('1.0', 'utf-8');

    // lx:response
    $this->rootNode = $this->document->createElement('lx:response');
    $this->rootNode->setAttribute('xmlns:lx', LX_NAMESPACE);
    $this->rootNode->setAttribute('host', $_SERVER['HTTP_HOST']);
    $this->rootNode->setAttribute('date', time());
    $this->rootNode->setAttribute('document-root', LX_DOCUMENT_ROOT);
    $this->rootNode->setAttribute('debug', LX_DEBUG ? 'true' : 'false');
    $this->document->appendChild($this->rootNode);

    // lx:request
    $this->requestNode = $this->document->createElement('lx:request');
    $this->rootNode->appendChild($this->requestNode);

    // lx:argument
    $this->argumentNode = $this->document->createElement('lx:arguments');
    foreach ($_GET as $key => $value)
      $this->appendArgument($value, $key);
    foreach ($_POST as $key => $value)
      $this->appendArgument($value, $key);

    $this->requestNode->appendChild($this->argumentNode);
  }

  private function appendArgument($value, $name = NULL)
  {
    if (is_array($value))
      $this->appendArgumentArrayValue($this->argumentNode, $name, $value);
    else
    {
      $valueNode = $this->document->createElement($name ? $name : 'lx:argument');
      $valueNode->nodeValue = $value;
      $this->argumentNode->appendChild($valueNode);
    }
  }

  private function appendArgumentArrayValue($owner, $name, $value)
  {
    foreach ($value as $k => $v)
    {
      $nodeName = is_numeric($k) ? $name . '_' . $k : $k;
      $valueNode = $this->document->createElement($nodeName);

      if (is_array($v))
	$this->appendArgumentArrayValue($valueNode, $nodeName, $v);
      else
	$valueNode->nodeValue = $v;

      $owner->appendChild($valueNode);
    }
  }

  public function appendController($my_controller, $my_arguments)
  {
    $node = LX::getResponse()->getDocument()->createElement('lx:controller');
    $fragment = $my_controller->getFragment();

    if ($fragment->hasAttributes() || $fragment->hasChildNodes())
      $node->appendChild($fragment);

    $this->rootNode->appendChild($node);

    foreach ($my_arguments as $value)
      $this->appendArgument($value);
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

    // request node
    if (LX_MODULE)
      $this->requestNode->setAttribute('module', LX_MODULE);
    $this->requestNode->setAttribute('controller', LX_CONTROLLER);
    if (LX_ACTION)
      $this->requestNode->setAttribute('action', LX_ACTION);
    if (LX_HANDLER)
      $this->requestNode->setAttribute('handler', LX_HANDLER);

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