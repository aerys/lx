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
  protected $layout		= LX_DEFAULT_LAYOUT;
  protected $template		= LX_DEFAULT_TEMPLATE;

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
    /*foreach ($_GET as $key => $value)
      $this->appendArgument($value, $key);
    foreach ($_POST as $key => $value)
    $this->appendArgument($value, $key);*/

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

  public function addXMLNamespace($my_namespace, $my_uri)
  {
    $this->rootNode->setAttribute('xmlns:' . $my_namespace, $my_uri);
  }

  public function appendDebugMessage($my_msg)
  {
    if (!LX_DEBUG)
      return ;

    $this->debugFragment->appendXML($my_msg);
  }

  public function appendArguments($value, $source)
  {
    if (!count($value))
      return ;

    $node = $this->document->createElement($source);

    foreach ($value as $k => $v)
    {
      $nodeName = is_numeric($k) ? 'arg' . $k : $k;
      $valueNode = $this->document->createElement($nodeName);

      if (is_string($v) && get_magic_quotes_gpc())
        $v = stripslashes($v);

      $valueNode->nodeValue = htmlentities($v);
      $node->appendChild($valueNode);
    }

    $this->argumentsNode->appendChild($node);
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
    $trace_cdata = $this->document->createCDATASection($my_exception->getTraceAsString());
    $trace_node->appendChild($trace_cdata);

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

  protected function httpHeader()
  {
    header('Content-type: text/xml; charset="utf-8"');
  }

  protected function finalize()
  {
    // lx:response
    $this->rootNode->setAttribute('time', abs(microtime() - $this->start_time) * 1000);

    // lx:request
    if (defined('LX_MODULE') && LX_MODULE)
      $this->requestNode->setAttribute('module', LX_MODULE);
    if (defined('LX_CONTROLLER') && LX_CONTROLLER)
    $this->requestNode->setAttribute('controller', LX_CONTROLLER);
    if (defined('LX_ACTION') && LX_ACTION)
      $this->requestNode->setAttribute('action', LX_ACTION);
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

    $this->httpHeader();
  }

  public function send()
  {
    $this->finalize();

    $this->document->save('php://output');
  }

}

?>