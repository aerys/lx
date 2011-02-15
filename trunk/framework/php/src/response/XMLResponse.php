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

  protected $filters            = array();

  public function setView($view)
  {
    $filename = LX_APPLICATION_ROOT . '/src/views/' . $view;

    if (LX_DEBUG && !file_exists($filename))
      throw new Exception('The view "' . $view . '" does not exist.');
    $this->view = $view;
  }
  public function setLayout($layout)
  {
    $filename = LX_APPLICATION_ROOT . '/src/views/' . $this->view . '/layouts/'
                . $layout . '.xml';

    if (LX_DEBUG && !file_exists($filename))
      throw new Exception('The layout "' . $layout . '" does not exist.');
    $this->layout = $layout;
  }

  public function setTemplate($template)
  {
    $filename = LX_APPLICATION_ROOT . '/src/views/' . $this->view . '/templates/'
                . $template;

    if (LX_DEBUG && !file_exists($filename . '.xml')
        && !file_exists($filename . '.xsl'))
      throw new Exception('The template "' . $template . '" does not exist.');
    $this->template = $template;
  }

  public function getDocument()			{ return $this->document; }
  public function getView()			{ return $this->view; }
  public function getLayout()			{ return $this->layout; }
  public function getTemplate()			{ return $this->template; }
  public function getDate()			{ return $this->date; }

  public function getFilter($name)              { return $this->filters[$name]; }

  public function XMLResponse()
  {
    $this->start_time = microtime();
    $this->date = isset($_SERVER['REQUEST_TIME'])
                  ? (int)$_SERVER['REQUEST_TIME']
                  : time();

    $this->document = new DOMDocument('1.0', 'utf-8');

    // lx:response
    $this->rootNode = $this->document->createElement('lx:response');
    $this->rootNode->setAttribute('xmlns:lx', LX_NAMESPACE);
    $this->rootNode->setAttribute('host', LX_HOST);
    $this->rootNode->setAttribute('date', $this->date);
    $this->rootNode->setAttribute('documentRoot', LX_DOCUMENT_ROOT);
    $this->rootNode->setAttribute('debug', LX_DEBUG ? 'true' : 'false');
    $this->document->appendChild($this->rootNode);

    // lx:request
    $this->requestNode = $this->document->createElement('lx:request');
    if (is_bool(LX_CLIENT_XSL_SUPPORT))
      $this->requestNode->setAttribute('clientXslSupport',
                                       LX_CLIENT_XSL_SUPPORT ? 'true' : 'false');
    if (defined('LX_REQUEST_EXTENSION'))
      $this->requestNode->setAttribute('extension',
                                       LX_REQUEST_EXTENSION);
    $this->rootNode->appendChild($this->requestNode);

    // lx:arguments
    $this->argumentsNode = $this->document->createElement('lx:arguments');
    /*if (($xml = XML::node('get', $_GET) . XML::node('post', $_POST)))
    {
      $argsFragment = $this->document->createDocumentFragment();
      $argsFragment->appendXML($xml);
      $this->argumentsNode->appendChild($argsFragment);
      }*/
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

    $f = $this->document->createDocumentFragment();
    $f->appendXML(XML::serialize($value, $source));

    $this->argumentsNode->appendChild($f);
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
    if (LX_DEBUG && ($this->debugFragment->hasAttributes() || $this->debugFragment->hasChildNodes()))
      $this->debugNode->appendChild($this->debugFragment);

    $this->httpHeader();
  }

  public function send()
  {
    $this->finalize();

    $this->document->save('php://output');
  }

  public function handleRequest($request)
  {
    global $_LX;

    $map	= $_LX['map'];
    $module	= '';
    $controller	= LX_DEFAULT_CONTROLLER;
    $action	= '';
    $filters	= $_LX['map']['filters'];
    $extension	= null;
    $view       = LX_DEFAULT_VIEW;
    $layout     = LX_DEFAULT_LAYOUT;
    $template   = LX_DEFAULT_TEMPLATE;

    // cut the request
    preg_match_all("/\/([^\/]+)/", $request, $params);
    $params = $params[1];

    // module
    if (count($params) && isset($map['modules'][$params[0]]))
      $module = array_shift($params);
    else if (isset($map['modules'][LX_DEFAULT_MODULE]))
      $module = LX_DEFAULT_MODULE;

    if (isset($map['modules'][$module]))
    {
      $map = $map['modules'][$module];

      if (isset($map['filters']))
        $filters = array_merge($filters, $map['filters']);

      if (isset($map['view']))
        $view = $map['view'];
      if (isset($map['layout']))
        $layout = $map['layout'];
      if (isset($map['template']))
        $template = $map['template'];
    }

    // controller
    $map = $map['controllers'];
    if (count($params) && isset($map[$params[0]]))
      $controller = array_shift($params);
    if (isset($map[$controller]))
    {
      $action = $map[$controller]['default_action'];
      $map = $map[$controller];

      if (isset($map['filters']))
        $filters = array_merge($filters, $map['filters']);

      if (isset($map['view']))
        $view = $map['view'];
      if (isset($map['layout']))
        $layout = $map['layout'];
      if (isset($map['template']))
        $template = $map['template'];
    }
    else
    {
      throw new Exception('No suitable controller could be found.'
                          . ' Check your lx:map in the project file.');
    }

    // action
    $map = $map['actions'];
    if (count($params) && isset($map[$params[0]]))
      $action = array_shift($params);
    if (isset($map[$action]))
    {
      $map = $map[$action];
      if (isset($map['filters']))
        $filters = array_merge($filters, $map['filters']);

      if (isset($map['view']))
        $view = $map['view'];
      if (isset($map['layout']))
        $layout = $map['layout'];
      if (isset($map['template']))
        $template = $map['template'];
    }

    $this->setView($view);
    $this->setLayout($layout);
    $this->setTemplate($template);

    return array($filters, $module, $controller, $action, $params);
  }
}

?>
