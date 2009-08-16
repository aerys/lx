<?php

class Dispatcher
{
  protected $response	= NULL;

  public function Dispatcher()
  {
    $_SESSION['LX_OUTPUT'] = isset($_GET['LX_OUTPUT'])? $_GET['LX_OUTPUT'] : LX_DEFAULT_OUTPUT;
    $this->response = $_SESSION['LX_OUTPUT'] == 'xhtml' ? new XHTMLResponse() : new XMLResponse();

    LX::setResponse($this->response);
  }

  public function dispatch()
  {
    global $_LX;

    try
    {
      $map		= $_LX['map'];
      $module		= '';
      $controller	= LX_DEFAULT_CONTROLLER;
      $action		= 'defaultAction';
      $filters		= $_LX['map']['filters'];
      $request		= $_SERVER['REDIRECT_URL'];

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
      $filters = array_merge($filters, $map[$controller]['filters']);

      // action
      if (isset($params[0]) && $params[0])
	$action = array_shift($params);

      define('LX_MODULE', $module);
      define('LX_CONTROLLER', $controller);
      define('LX_ACTION', $action);

      if (LX_MODULE)
	LX::addApplicationDirectory('/src/controllers/' . LX_MODULE);

      // filters
      foreach ($filters as $filterName => $filterClass)
      {
	$filter = new $filterClass();
	$filter_result = $filter->filter();

	if (!(false === $filter_result))
	  $this->response->appendFilter($filter, $filterName);
      }

      // create a new controller instance
      $class = $map[LX_CONTROLLER]['class'];
      $cont = new $class();

      // cal the controller's action
      call_user_func_array(array($cont, $action), $params);

      $this->response->appendController($cont, LX_CONTROLLER, LX_ACTION);
    }
    catch (FilterException $e)
    {
      if ($e->getView())
	LX::setView($e->getView());
      if ($e->getLayout())
	LX::setLayout($e->getLayout());
      if ($e->getTemplate())
	LX::setTemplate($e->getTemplate());
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