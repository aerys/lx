<?php

class XMLResponse extends AbstractResponse
{
  protected $document		= NULL;
  protected $rootNode		= NULL;
  protected $requestNode	= NULL;
  protected $argumentsNode	= NULL;
  protected $filtersNode	= NULL;

  protected $debugNode		= NULL;
  protected $debugFragment	= NULL;

  public function getDocument() { return $this->document; }

  public function XMLResponse()
  {
    parent::AbstractResponse();

    $this->document = new DOMDocument('1.0', 'utf-8');

    // lx:response
    $this->rootNode = $this->document->createElement('lx:response');
    $this->rootNode->setAttribute('xmlns:lx', LX_NAMESPACE);
    $this->rootNode->setAttribute('host', LX_HOST);
    $this->rootNode->setAttribute('date', $this->date);
    $this->rootNode->setAttribute('protocol', isset($_SERVER['HTTPS']) ? 'https' : 'http');
    $this->rootNode->setAttribute('method', strtolower($_SERVER['REQUEST_METHOD']));
    if (LX_DOCUMENT_ROOT != '/')
      $this->rootNode->setAttribute('documentRoot', LX_DOCUMENT_ROOT);
    if (LX_DEBUG)
      $this->rootNode->setAttribute('debug', 'true');
    $this->document->appendChild($this->rootNode);

    // lx:request
    $this->requestNode = $this->document->createElement('lx:request');
//    $this->requestNode->setAttribute('query', $_SERVER['REQUEST_URI']);
    if (is_bool(LX_CLIENT_XSL_SUPPORT))
      $this->requestNode->setAttribute('clientXslSupport',
                                       LX_CLIENT_XSL_SUPPORT ? 'true' : 'false');
    if (defined('LX_REQUEST_EXTENSION'))
      $this->requestNode->setAttribute('extension',
                                       LX_REQUEST_EXTENSION);
    $this->rootNode->appendChild($this->requestNode);

    // lx:arguments
    $this->argumentsNode = $this->document->createElement('lx:arguments');

    //lx:filter
    $this->filtersNode = $this->document->createElement('lx:filters');

    //lx:debug
    if (LX_DEBUG)
    {
      $this->debugNode = $this->document->createElement('lx:debug');
      $this->debugFragment = $this->document->createDocumentFragment();

      $this->rootNode->appendChild($this->debugNode);
    }
  }

  public function handleRequest($request)
  {
    if (count($_GET))
      $this->appendArguments($_GET, 'get');

    if (count($_POST))
      $this->appendArguments($_POST, 'post');

   return parent::handleRequest($request);
  }

  public function addXMLNamespace($namespace, $uri)
  {
    $this->rootNode->setAttribute('xmlns:' . $namespace, $uri);
  }

  public function appendDebugMessage($msg)
  {
    if (!LX_DEBUG)
      return ;

    $this->debugFragment->appendXML($msg);
  }

  public function appendArguments($values, $source)
  {
    if (!count($values))
      return ;

    $f = $this->document->createDocumentFragment();
    if ($source == 'url')
    {
      foreach ($values as $value)
        if (is_string($value))
          $f->appendXML(XML::node($source, $value));
    }
    else
    {
      $f->appendXML(XML::node($source, $values));
    }

    $this->argumentsNode->appendChild($f);
  }

  public function appendController($controller)
  {
    $node = LX::getResponse()->getDocument()->createElement('lx:controller');
    $fragment = $controller->getFragment();

    if ($fragment->hasAttributes() || $fragment->hasChildNodes())
      $node->appendChild($fragment);

    $this->rootNode->appendChild($node);
  }

  public function appendErrorException($exception)
  {
    $node = $this->document->createElement('lx:error');
    $node->setAttribute('type', get_class($exception));

    $trace_node = $this->document->createElement('trace');

    $trace_text = $exception->getTraceAsString();
    $frames = explode("\n", $trace_text);

    foreach ($frames as $frame)
    {
      $frame_node = $this->document->createElement('frame');
      $frame_cdata = $this->document->createCDATASection($frame);
      $frame_node->appendChild($frame_cdata);
      $trace_node->appendChild($frame_node);
    }

    $message = $this->document->createElement('message');
    $message->nodeValue = $exception->getMessage();

    $node->appendChild($message);
    $node->appendChild($trace_node);

    $this->rootNode->appendChild($node);
  }

  public function appendException($exception)
  {
    $node = $this->document->createElement('lx:exception');
    $node->setAttribute('type', get_class($exception));

    $node->nodeValue = $exception->getMessage();

    $this->rootNode->appendChild($node);
  }

  public function appendFilter($filter, $name)
  {
    $this->filters[$name] = $filter;

    $node = $this->document->createElement($name);
    $fragment = $filter->getFragment();

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
    $time = abs((microtime() - $this->start_time)) * 1000;
    $this->rootNode->setAttribute('time', $time);

    // lx:request
    if (defined('LX_MODULE') && LX_MODULE)
      $this->requestNode->setAttribute('module', LX_MODULE);
    if (defined('LX_CONTROLLER') && LX_CONTROLLER)
      $this->requestNode->setAttribute('controller', LX_CONTROLLER);
    if (defined('LX_ACTION') && LX_ACTION)
      $this->requestNode->setAttribute('action', LX_ACTION);
    if ($this->argumentsNode->hasChildNodes())
      $this->requestNode->appendChild($this->argumentsNode);

    if ($this->filtersNode->hasChildNodes())
      $this->rootNode->insertBefore($this->filtersNode,
                                    $this->requestNode->nextSibling);

    // insert view node
    $viewCfg = $this->document->createElement('lx:view');
    $viewCfg->setAttribute('name', $this->view);
    $viewCfg->setAttribute('layout', $this->layout);
    $viewCfg->setAttribute('template', $this->template);
    $this->rootNode->insertBefore($viewCfg, $this->rootNode->firstChild);

    //lx:debug
    if (LX_DEBUG && ($this->debugFragment->hasAttributes()
                     || $this->debugFragment->hasChildNodes()))
    {
      $this->debugNode->appendChild($this->debugFragment);
    }

    $this->httpHeader();
  }

  public function send()
  {
    $this->finalize();

    $this->document->save('php://output');
  }

}

?>
