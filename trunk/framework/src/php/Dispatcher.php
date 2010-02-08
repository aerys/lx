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
      $extension	= NULL;

      // delete document root from the URL
      if (LX_DOCUMENT_ROOT != '/')
	$request = str_replace(LX_DOCUMENT_ROOT, '', $request);

      // response handler
      $pos = strrpos($request, '.');
      if (false != $pos)
      {
	$extension = substr($request, $pos + 1);
	$request = substr($request, 0, $pos);
      }

      if ($extension && isset($_LX['responses'][$extension]))
      {
	define('LX_HANDLER', $extension);

	if ($_LX['responses'][$extension])
	  $this->response = new $_LX['responses'][$extension]();
	else
	  $this->response = new XSLResponse();
      }
      else if ($extension == 'xml')
      {
	define('LX_HANDLER', 'xml');
	$this->response = new XMLResponse();
      }
      else if ($extension == 'lxml')
      {
	define('LX_HANDLER', 'lxml');
	$this->response = new LXMLResponse();
      }
      else
      {
	if ($extension && $extension != 'xsl')
	  $request .= '.' . $extension;
	define('LX_HANDLER', 'xsl');
	$this->response = new XSLResponse();
      }
      LX::setResponse($this->response);

      // cut the request
      preg_match_all("/\/([^\/]+)/", $request, $params);
      $params = $params[1];

      // module
      if (count($params) && isset($map['modules'][$params[0]]))
      {
	$module = array_shift($params);
	$map = $map['modules'][$module];
	$module = $map['dir'];
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
      {
	$action = $map[$controller]['default_action'];
	$filters = array_merge($filters, $map[$controller]['filters']);
      }

      // action
      $actionsMap = $map[$controller]['actions'];
      if (count($params) && isset($actionsMap[$params[0]]))
	$action = array_shift($params);
      if (isset($actionsMap[$action]))
	$filters = array_merge($filters, $actionsMap[$action]['filters']);

      define('LX_MODULE', $module);
      define('LX_CONTROLLER', $controller);
      define('LX_ACTION', $action);

      if (!isset($map[LX_CONTROLLER]))
	throw new UnknownControllerException(LX_CONTROLLER);

      //if (LX_MODULE)
      //LX::addApplicationDirectory('/src/controllers/' . LX_MODULE);

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
      {
	foreach ($params as $argv)
	  $this->response->appendArgument($argv);

	call_user_func_array(array($cont, $action), $params);
      }

      $this->response->appendController($cont);
    }
    catch (FilterException $e)
    {
      if (LX_DEBUG)
	LX::getResponse()->appendErrorException($e);
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