<?php

require_once ('../application/tmp/lx-project.php');

try
{
  LX::setResponse(new XMLResponse());

  // read values from request
  $params = explode('/', substr($_SERVER['REDIRECT_URL'], 1));
  $controlerName = $params[0] ? $params[0] : 'home';
  $action = count($params) >= 2 && $params[1] ? $params[1] : 'defaultAction';

  // get the controler class
  $controlerClass = $_LX['CONTROLERS'][$controlerName];
  // create a new controler instance
  $controler = new $controlerClass();

  $response = LX::getResponse();

  $controler->$action();
  $response->appendControler($controler, $controlerName, $action);
}
catch (Exception $e)
{
  LX::getResponse()->appendException($e);
}

// send response
echo LX::getResponse()->save();

?>