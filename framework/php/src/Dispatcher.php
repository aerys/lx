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
			$extension	= null;

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

				$response = new $_LX['responses'][LX_DEFAULT_EXTENSION]();
				if (!LX_CLIENT_XSL_SUPPORT && $response instanceof XSLResponse)
					$response = new LXMLResponse();

				$this->response = $response;
			}
			LX::setResponse($this->response);

			list($filters, $module, $controller, $action, $params) = $this->response->handleRequest($request, $_GET);

			define('LX_MODULE',       $module);
			define('LX_CONTROLLER',   $controller);
			define('LX_ACTION',       $action);

			if (LX_MODULE)
				$map = $map['modules'][LX_MODULE];
			$class = $map['controllers'][LX_CONTROLLER]['class'];
			$actionsMap = $map['controllers'][LX_CONTROLLER]['actions'];

			// create a new controller instance
			if (!isset($map['controllers'][LX_CONTROLLER]))
				throw new UnknownControllerException(LX_CONTROLLER);

			// arguments
			$this->response->appendArguments($params, 'url');

			// start buffering
			ob_start();

			// filters
			foreach ($filters as $filterName => $filterClass)
			{
				$this->filterName = $filterName;
				$filter = new $filterClass();
				$filter_result = $filter->filter();
				$ob_output = ob_get_contents();

				ob_clean();

				if (FilterResult::IGNORE !== $filter_result)
				{
					if ($ob_output)
						$filter->getFragment()->appendXML($ob_output);
						
					if ($filter_result && $filter_result !== FilterResult::OK
						&& $filter_result !== FilterResult::STOP)
					{
						$filter->getFragment()->appendXML(XML::serialize($filter_result));
					}

					$this->response->appendFilter($filter, $filterName);
				}

				if (FilterResult::STOP === $filter_result)
					break ;
			}

			// call the controller's action
			$cont     = new $class();
			$result   = null;
			if ($action)
			{
				$context = array($cont, $actionsMap[$action]['method']);
				foreach ($params as $key => $value)
					$params[$key] = urldecode($value);

				$result = call_user_func_array($context, $params);
			}

			if ($result !== null)
				echo XML::serialize($result);

			if (($ob_output = ob_get_clean()))
				$cont->getFragment()->appendXML($ob_output);

			$this->response->appendController($cont);

			// stop buffering
			//ob_end_clean();
		}
		catch (FilterException $e)
		{
			if (($ob_output = ob_get_clean()))
				$e->getFilter()->getFragment()->appendXML($ob_output);
			if (($data = $e->getData()))
				$e->getFilter()->getFragment()->appendXML(XML::serialize($data));

			$this->response->appendFilter($e->getFilter(), $this->filterName);
		}
		catch (ErrorException $e)
		{
			if (ob_get_level() !== 0)
				ob_end_clean();

			if (LX_DEBUG)
			{
				if ($this->response)
					$this->response->appendErrorException($e);
				else
					echo $e->getMessage();
			}
		}
		catch (Exception $e)
		{
			ob_end_clean();

			$this->response->appendException($e);
		}

		// send response
		LX::getResponse()->send();
	}
}

?>
