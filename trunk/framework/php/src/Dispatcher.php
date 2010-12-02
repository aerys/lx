<?php

class Dispatcher
{
  private static $instance	= NULL;

  protected $response	= NULL;

  private $filterName   = NULL;

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

      if (($pos = strpos($request, '?')) !== false)
        $request = substr($request, 0, $pos);

      // delete document root from the URL
      if (LX_DOCUMENT_ROOT != '/')
	$request = str_replace(LX_DOCUMENT_ROOT, '', $request);

      // response handler

      if (($pos = strrpos($request, '.')) !== false)
      {
	$extension = substr($request, $pos + 1);
	$request = substr($request, 0, $pos);
      }

      if ($extension && isset($_LX['responses'][$extension]))
      {
          define('LX_REQUEST_EXTENSION', $extension);
      	  $this->response = new $_LX['responses'][$extension]();
      }
      else
      {
	if ($extension)
	  $request .= '.' . $extension;

        define('LX_REQUEST_EXTENSION', LX_DEFAULT_EXTENSION);
	$this->response = new $_LX['responses'][LX_DEFAULT_EXTENSION]();
      }
      LX::setResponse($this->response);

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

      // arguments
      $this->response->appendArguments($params, 'url');
      $this->response->appendArguments($get, 'get');
      $this->response->appendArguments($post, 'post');

      //if (LX_MODULE)
      //LX::addApplicationDirectory('/src/controllers/' . LX_MODULE);

      // start buffering
      ob_start();

      // filters
      foreach ($filters as $filterName => $filterClass)
      {
        $this->filterName = $filterName;
	$filter = new $filterClass();
	$filter_result = $filter->filter();
        $ob_output = ob_get_clean();

	if (FilterResult::IGNORE !== $filter_result)
        {
          if ($ob_output)
            $filter->getFragment()->appendXML('<![CDATA[' . $ob_output . ']]>');

	  $this->response->appendFilter($filter, $filterName);
        }

	if (FilterResult::STOP === $filter_result)
	  break ;
      }

      // create a new controller instance
      $class = $map[LX_CONTROLLER]['class'];
      $cont = new $class();

      // call the controller's action
      $result = null;
      if ($action)
      {
	$result = call_user_func_array(array($cont,
                                             $actionsMap[$action]['method']),
                                       $params);
      }

      if (($ob_output = ob_get_clean()))
        $cont->getFragment()->appendXML('<![CDATA[' . $ob_output . ']]>');

      if ($result)
      {
        if (is_string($result))
          $cont->getFragment()->appendXML($result);
        if ($result instanceof XMLSerializable)
          $cont->getFragment()->appendXML($result->__toString());
        else if (is_array($result))
          foreach ($result as $resultItem)
            if ($resultItem instanceof XMLSerializable)
              $cont->getFragment()->appendXML($resultItem->__toString());
      }
      $this->response->appendController($cont);

      // stop buffering
      //ob_end_clean();
    }
    catch (FilterException $e)
    {
      $ob_output = ob_get_clean();
      if ($ob_output)
        $e->getFilter()->getFragment()->appendXML($ob_output);

      $this->response->appendFilter($e->getFilter(), $this->filterName);
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
    LX::getResponse()->send();
  }
}

?>
