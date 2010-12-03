<?php

class LX
{
  static private $dispatcher		= NULL;
  static private $response		= NULL;
  static private $directories		= array('/',
						'/database',
						'/database/mysql',
						'/exception',
						'/filter',
						'/response');
  static private $app_directories	= array('/src',
						'/src/models',
						'/src/controllers',
						'/src/filters',
						'/bin',
						'/bin/models');

  static public function setResponse($my_response)	{self::$response = $my_response;}
  static public function getResponse()			{return (self::$response);}

  static public function getDatabaseConfiguration($my_name)
  {
    global $_LX;

    return (isset($_LX['databases'][$my_name]) ? $_LX['databases'][$my_name] : NULL);
  }

  static public function disableErrors()
  {
    restore_error_handler();
  }

  static public function enableErrors()
  {
    set_error_handler('lx_error_handler');
  }

  static public function redirect($url)
  {
    $root = LX_DOCUMENT_ROOT == '/' ? '/'
                                    : LX_DOCUMENT_ROOT . '/';
    $pattern = '/^[a-z]+:\/\/' . LX_HOST . str_replace($root, '/', '\/') . '.*$/s';
    $external = !preg_match($pattern, $url);

    if (!$external)
    {
      if ($url[0] != '/' && LX_DOCUMENT_ROOT != '/')
        $url = '/' . $url;

      $url = LX_DOCUMENT_ROOT . $url;
    }

    header('Location: ' . $url);

    exit ;
  }

  static public function setView($view)
  {
    self::$response->setView($view);
  }

  static public function setLayout($layout)
  {
    self::$response->setLayout($layout);
  }

  static public function setTemplate($template)
  {
    self::$response->setTemplate($template);
  }

  static public function autoload($class_name)
  {
    foreach (self::$directories as $directory)
    {
      $filename = LX_SRC . $directory . '/' . $class_name . '.php';

      if (file_exists($filename))
      {
	require_once ($filename);

	return ;
      }
    }

    foreach (self::$app_directories as $directory)
    {
      $filename = LX_APPLICATION_ROOT . $directory . '/' . $class_name . '.php';

      if (file_exists($filename))
      {
	require_once ($filename);

	return ;
      }
    }
  }

  static public function appendDebugMessage($msg)
  {
    if (self::$response)
      self::$response->appendDebugMessage($msg);
  }

  static public function addApplicationDirectory($directory)
  {
    self::$app_directories[] = $directory;
  }

  static public function dispatchHTTPRequest($url, $get, $post)
  {
    Dispatcher::get()->dispatchHTTPRequest($url, $get, $post);
  }

  static public function print_r($myVariable)
  {
    $str = htmlentities(print_r($myVariable, true));

    return $str;
  }
}

function __autoload($class_name)
{
  LX::autoload($class_name);
}

function lx_error_handler($errno,
			  $errstr,
			  $errfile,
			  $errline,
			  $context)
{
  // FIXME
  throw new ErrorException($errstr, 0, $errno, $errfile, $errline);

  /* Don't execute PHP internal error handler */
  return (true);
}

set_error_handler('lx_error_handler');

?>