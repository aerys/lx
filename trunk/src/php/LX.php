<?php



class LX
{
  static private $response		= NULL;
  static private $directories		= array('/',
						'/database',
						'/database/mysql',
						'/exception',
						'/filter');
  static private $app_directories	= array('/src/models',
						'/src/controllers',
						'/src/filters',
						'/tmp',
						'/tmp/models');

  static public function setResponse($my_response)	{self::$response = $my_response;}
  static public function getResponse()			{return (self::$response);}

  static public function getDatabaseConfiguration($my_name)
  {
    global $_LX;

    return (isset($_LX['DATABASES'][$my_name]) ? $_LX['DATABASES'][$my_name] : NULL);
  }

  static public function disableErrors()
  {
    restore_error_handler();
  }

  static public function enableErrors()
  {
    set_error_handler('lx_error_handler');
  }

  static public function redirect($my_module,
				  $my_controller	= NULL,
				  $my_action		= NULL,
				  $my_arguments		= NULL)
  {
    $url = 'http://' . $_SERVER['HTTP_HOST'] . (LX_DOCUMENT_ROOT != '/' ? LX_DOCUMENT_ROOT . '/' : '/');

    if ($my_module)
      $url .= $my_module . '/';
    if ($my_controller)
      $url .= $my_controller;
    if ($my_action)
      $url .= '/' . $my_action;

    if ($my_arguments != NULL && count($my_arguments))
    {
      $url .= '/';

      foreach ($my_arguments as $value)
      {
	$url .= $value;
	if ($value != end($my_arguments))
	  $url .= '/';
      }
    }

    header('Location: ' . $url);
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

  static public function addApplicationDirectory($my_directory)
  {
    self::$app_directories[] = $my_directory;
  }
}

?>