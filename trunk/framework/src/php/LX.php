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

  static public function redirect($myURL)
  {
    header('Location: ' . LX_DOCUMENT_ROOT . $myURL);

    exit ;
  }

  static public function setView($my_view)
  {
    self::$response->setView($my_view);
  }

  static public function setLayout($my_layout)
  {
    self::$response->setLayout($my_layout);
  }

  static public function setTemplate($my_template)
  {
    self::$response->setTemplate($my_template);
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

  static public function appendDebugMessage($my_msg)
  {
    if (self::$response)
      self::$response->appendDebugMessage($my_msg);
  }

  static public function addApplicationDirectory($my_directory)
  {
    self::$app_directories[] = $my_directory;
  }

  static public function dispatchHTTPRequest($url, $get, $post)
  {
    Dispatcher::get()->dispatchHTTPRequest($url, $get, $post);
  }

}

function __autoload($class_name)
{
  LX::autoload($class_name);
}

function lx_error_handler($my_errno,
			  $my_errstr,
			  $my_errfile,
			  $my_errline,
			  $my_context)
{
  // FIXME
  throw new ErrorException($my_errstr, 0, $my_errno, $my_errfile, $my_errline);

  /* Don't execute PHP internal error handler */
  return (true);
}

set_error_handler('lx_error_handler');

?>