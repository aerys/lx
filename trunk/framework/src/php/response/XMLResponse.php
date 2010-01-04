<?php

class XMLResponse
{
  protected $document		= NULL;
  protected $rootNode		= NULL;
  protected $requestNode	= NULL;
  protected $argumentsNode	= NULL;
  protected $filtersNode	= NULL;

  protected $debugNode		= NULL;
  protected $debugFragment	= NULL;

  protected $view		= LX_DEFAULT_VIEW;
  protected $layout		= 'index';
  protected $template		= 'default';

  protected $date		= 0;
  protected $start_time		= 0;

  public function setView($my_view)		{$this->view = $my_view;}
  public function setLayout($my_layout)		{$this->layout = $my_layout;}
  public function setTemplate($my_temp)		{$this->template = $my_temp;}

  public function getDocument()			{return ($this->document);}
  public function getView()			{return ($this->view);}
  public function getLayout()			{return ($this->layout);}
  public function getTemplate()			{return ($this->template);}
  public function getDate()			{return ($this->date);}

  public function XMLResponse()
  {
    $this->start_time = microtime();
    $this->date = time();

    $this->document = new DOMDocument('1.0', 'utf-8');

    // lx:response
    $this->rootNode = $this->document->createElement('lx:response');
    $this->rootNode->setAttribute('xmlns:lx', LX_NAMESPACE);
    $this->rootNode->setAttribute('host', $_SERVER['HTTP_HOST']);
    $this->rootNode->setAttribute('date', $this->date);
    $this->rootNode->setAttribute('document-root', LX_DOCUMENT_ROOT);
    $this->rootNode->setAttribute('debug', LX_DEBUG ? 'true' : 'false');
    $this->document->appendChild($this->rootNode);

    // lx:request
    $this->requestNode = $this->document->createElement('lx:request');
    $this->rootNode->appendChild($this->requestNode);

    // lx:arguments
    $this->argumentsNode = $this->document->createElement('lx:arguments');
    foreach ($_GET as $key => $value)
      $this->appendArgument($value, $key);
    foreach ($_POST as $key => $value)
      $this->appendArgument($value, $key);

    //lx:filter
    $this->filtersNode = $this->document->createElement('lx:filters');
    $this->rootNode->appendChild($this->filtersNode);

    //lx:debug
    if (LX_DEBUG)
    {
      $this->debugNode = $this->document->createElement('lx:debug');
      $this->debugFragment = $this->document->createDocumentFragment();

      $this->rootNode->appendChild($this->debugNode);
    }
  }

  public function appendDebugMessage($my_msg)
  {
    if (!LX_DEBUG)
      return ;

    $this->debugFragment->appendXML($my_msg);
  }

  public function appendArgument($value, $name = NULL)
  {
    if (is_array($value))
      $this->appendArgumentArrayValue($this->argumentsNode, $name, $value);
    else
    {
      $valueNode = $this->document->createElement($name ? $name : 'lx:argument');

      if (is_string($value) && get_magic_quotes_gpc())
	$value = stripslashes($value);

      $valueNode->nodeValue = $value;
      $this->argumentsNode->appendChild($valueNode);
    }
  }

  private function appendArgumentArrayValue($owner, $name, $value)
  {
    foreach ($value as $k => $v)
    {
      $nodeName = is_numeric($k) ? $name . '_' . $k : $k;
      $valueNode = $this->document->createElement($nodeName);

      if (is_array($v))
      {
	$this->appendArgumentArrayValue($valueNode, $nodeName, $v);
      }
      else
      {
	if (is_string($v) && get_magic_quotes_gpc())
	  $v = stripslashes($v);

	$valueNode->nodeValue = $v;
      }

      $owner->appendChild($valueNode);
    }
  }

  public function appendController($my_controller)
  {
    $node = LX::getResponse()->getDocument()->createElement('lx:controller');
    $fragment = $my_controller->getFragment();

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
    $node = $this->document->createElement($my_name);
    $fragment = $my_filter->getFragment();

    if ($fragment->hasAttributes() || $fragment->hasChildNodes())
      $node->appendChild($fragment);

    $this->filtersNode->appendChild($node);
  }

  protected function finalize()
  {
    // lx:response
    $this->rootNode->setAttribute('time', abs(microtime() - $this->start_time) * 1000);

    // lx:request
    if (LX_MODULE)
      $this->requestNode->setAttribute('module', LX_MODULE);
    $this->requestNode->setAttribute('controller', LX_CONTROLLER);
    if (LX_ACTION)
      $this->requestNode->setAttribute('action', LX_ACTION);
    if (LX_HANDLER)
      $this->requestNode->setAttribute('handler', LX_HANDLER);
    if ($this->argumentsNode->hasChildNodes())
      $this->requestNode->appendChild($this->argumentsNode);

    // insert view node
    $viewCfg = $this->document->createElement('lx:view');
    $viewCfg->setAttribute('name', $this->view);
    $viewCfg->setAttribute('layout', $this->layout);
    $viewCfg->setAttribute('template', $this->template);
    $this->rootNode->insertBefore($viewCfg, $this->rootNode->firstChild);

    //lx:debug
    if (LX_DEBUG && ($this->debugFragment->hasAttributes() || $this->debugFragment->hasChildNodes()))
      $this->debugNode->appendChild($this->debugFragment);
  }

  public function save($my_filename	= NULL)
  {
    header('Content-type: text/xml; charset="utf-8"');

    $this->finalize();

    if ($my_filename != NULL)
      return ($this->document->saveXML($my_filename));

    return ($this->document->saveXML());
  }

}

?>