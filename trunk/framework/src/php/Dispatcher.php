<?php

class Dispatcher
{
  private static $instance	= NULL;

  protected $response	= NULL;

  public static function get()
  {
    if (!self::$instance)
      self::$instance = new Dispatcher();

    return (self::$instance);
  }

  public function Dispatcher()
  {
    $output = isset($_GET['LX_OUTPUT'])? $_GET['LX_OUTPUT'] : LX_DEFAULT_OUTPUT;

    switch ($output)
    {
      case LX_OUTPUT_HTML:
	$this->response = new HTMLResponse();
	break;
      case LX_OUTPUT_XSL:
	$this->response = new XSLResponse();
	break ;
      default:
	$this->response = new XMLResponse();
    }

    LX::setResponse($this->response);
  }

  public function dispatchHTTPRequest($request, $get, $post)
  {
    global $_LX;

    try
    {
      $map		= $_LX['map'];
      $module		= '';
      $controller	= LX_DEFAULT_CONTROLLER;
      $action		= '';
      $filters		= $_LX['map']['filters'];

      if (LX_DOCUMENT_ROOT != '/')
	$request = str_replace(LX_DOCUMENT_ROOT, '', $request);

      preg_match_all("/\/([^\/]+)/", $request, $params);
      $params = $params[1];

      // module
      if (count($params) && isset($map['modules'][$params[0]]))
      {
	$module = array_shift($params);
	$map = $map['modules'][$module];
	$filters = array_merge($filters, $map['filters']);
      }
      else if (!(count($params) && isset($map['controllers'][$params[0]]))
	       && isset($map['modules'][LX_DEFAULT_MODULE]))
      {
	$module = LX_DEFAULT_MODULE;
	$map = $map['modules'][$module];
	$filters = array_merge($filters, $map['filters']);
      }

      // controller
      $map = $map['controllers'];
      if (count($params) && isset($map[$params[0]]))
	$controller = array_shift($params);
      if (isset($map[$controller]))
	$filters = array_merge($filters, $map[$controller]['filters']);

      // action
      if (isset($params[0]) && $params[0])
	$action = array_shift($params);
      else if (isset($map[$controller]['default-action']))
	$action = $map[$controller]['default-action'];

      define('LX_MODULE', $module);
      define('LX_CONTROLLER', $controller);
      define('LX_ACTION', $action);

      if (!isset($map[LX_CONTROLLER]))
	throw new UnknownControllerException(LX_CONTROLLER);

      if (LX_MODULE)
	LX::addApplicationDirectory('/src/controllers/' . LX_MODULE);

      // filters
      foreach ($filters as $filterName => $filterClass)
      {
	$filter = new $filterClass();
	$filter_result = $filter->filter();

	if (FilterResult::STOP === $filter_result)
	  break ;
	else if (!(FilterResult::IGNORE === $filter_result))
	  $this->response->appendFilter($filter, $filterName);
      }

      // create a new controller instance
      $class = $map[LX_CONTROLLER]['class'];
      $cont = new $class();

      // call the controller's action
      if ($action)
	call_user_func_array(array($cont, $action), $params);

      $this->response->appendController($cont, $params);
    }
    catch (FilterException $e)
    {
      LX::redirect($e->getRedirection());
    }
    catch (ErrorException $e)
    {
      if (LX_DEBUG)
	LX::getResponse()->appendErrorException($e);
    }
    catch (Exception $e)
    {
      LX::getResponse()->appendException($e);
    }

    // send response
    echo LX::getResponse()->save();
  }
}

?>