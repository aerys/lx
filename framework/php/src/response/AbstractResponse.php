<?php

class AbstractResponse
{
  protected $view	= LX_DEFAULT_VIEW;
  protected $layout	= LX_DEFAULT_LAYOUT;
  protected $template   = LX_DEFAULT_TEMPLATE;

  protected $date	= 0;
  protected $start_time	= 0;

  protected $filters    = array();

  public function getView()		{ return $this->view; }
  public function getLayout()		{ return $this->layout; }
  public function getTemplate()		{ return $this->template; }
  public function getDate()		{ return $this->date; }

  public function getFilter($name)      { return $this->filters[$name]; }

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
    {
      throw new Exception('The template "' . $template . '" does not exist.');
    }
    $this->template = $template;
  }

  public function AbstractResponse()
  {
    $this->start_time = microtime();
    $this->date = isset($_SERVER['REQUEST_TIME'])
                  ? (int)$_SERVER['REQUEST_TIME']
                  : time();
  }

  public function handleRequest($request)
  {
    global $_LX;

    $map	= $_LX['map'];
    $module	= '';
    $controller	= LX_DEFAULT_CONTROLLER;
    $action	= '';
    $filters	= $_LX['map']['filters'];
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
      throw new Exception('No suitable controller found.'
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