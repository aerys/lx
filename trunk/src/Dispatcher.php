<?php

class Dispatcher
{
  protected $response	= NULL;
  protected $testXSL	= false;

  public function Dispatcher()
  {
    $this->testXSL = empty($_SESSION['LX_OUTPUT']);

    $_SESSION['LX_OUTPUT'] = isset($_GET['LX_OUTPUT']) ? $_GET['LX_OUTPUT'] : LX_DEFAULT_OUTPUT;

    if ($_SESSION['LX_OUTPUT'] == 'xhtml')
      $this->response = new XHTMLResponse();
    else
      $this->response = new XMLResponse();

    LX::setResponse($this->response);
  }

  public function dispatch()
  {
    global $_LX;

    try
    {
      $map		= $_LX['map'];
      $module		= '';
      $controller	= 'home';
      $action		= 'defaultAction';
      $filters		= array();
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
	$filters = array_merge($map['filters']);
      }
      else if (isset($map['modules']['home']))
      {
	$module = 'home';
	$map = $map['modules'][$module];
	$filters = array_merge($map['filters']);
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

      // filters
      foreach ($filters as $filterName => $filterClass)
      {
	$filter = new $filterClass();
	$filter->filter();

	$this->response->appendFilter($filter, $filterName);
      }

      // create a new controller instance
      $class = $map[LX_CONTROLLER]['class'];
      $cont = new $class();

      call_user_func_array(array($cont, $action), $params);
      //$cont->$action();
      $this->response->appendController($cont, LX_CONTROLLER, LX_ACTION);
    }
    catch (FilterException $e)
    {
      if ($e->getView())
	LX::getResponse()->setView($e->getView());
      if ($e->getLayout())
	LX::getResponse()->setView($e->getLayout());
      if ($e->getMedia())
	LX::getResponse()->setView($e->getMedia());
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