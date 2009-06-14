<?php

class LX
{
  static private $response	= NULL;

  static public function setResponse($my_response)	{self::$response = $my_response;}
  static public function getResponse()			{return (self::$response);}

  static public function getDatabaseConfiguration($my_name)
  {
    global $_LX;

    if (isset($_LX['DATABASES'][$my_name]))
      return ($_LX['DATABASES'][$my_name]);

    return (NULL);
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
    $url = 'http://' . $_SERVER['HTTP_HOST'];

    $url .= LX_DOCUMENT_ROOT . '/';

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

  static public function setMedia($my_media)
  {
    self::$response->setMedia($my_media);
  }
}

?>