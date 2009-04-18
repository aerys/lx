<?php

require_once ('../tmp/lx-project.php');

try
{
  $start_time = microtime();

  $response = new XMLResponse();
  LX::setResponse($response);

  // read values from request
  $params = explode('/', substr($_SERVER['REDIRECT_URL'], 1));
  $controllerName = $params[0] ? $params[0] : 'home';
  $action = count($params) >= 2 && $params[1] ? $params[1] : 'defaultAction';

  define('LX_CONTROLLER_NAME', $controllerName);
  define('LX_ACTION', $action);

  // get the controller class
  if (!isset($_LX['CONTROLLERS'][$controllerName]))
    throw new UnknownControllerException($controllerName);

  $controllerClass = $_LX['CONTROLLERS'][$controllerName]['class'];

  if (isset($_LX['CONTROLLERS'][$controllerName]['filters']))
  {
    $filters = $_LX['CONTROLLERS'][$controllerName]['filters'];

    foreach ($filters as $filterName => $filterClass)
    {
      $filter = new $filterClass();
      $filter->filter();

      $response->appendFilter($filter, $filterName);
    }
  }

  // create a new controller instance
  $controller = new $controllerClass();

  $controller->$action();
  $response->appendController($controller, $controllerName, $action);

  $response->setTime((microtime() - $start_time) * 1000);
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
    LX::getResponse()->appendException($e);
}
catch (Exception $e)
{
  LX::getResponse()->appendException($e);
}


// send response
echo LX::getResponse()->save();

?>