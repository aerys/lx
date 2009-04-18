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

  static public function redirect($my_controler, $my_action = NULL)
  {
    header('Location: /' . $my_controler . ($my_action ? '/' . $my_action : ''));
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