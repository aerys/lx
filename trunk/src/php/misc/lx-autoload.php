<?php

function __autoload($class_name)
{
  //class directories
  $directories = array(LX_SRC,
		       LX_SRC . '/exceptions',
		       LX_SRC . '/database',
		       LX_SRC . '/database/mysql');
  if (defined('LX_APPLICATION_ROOT'))
  {
    $directories[] = LX_APPLICATION_ROOT . '/src/models';
    if (defined('LX_MODULE') && LX_MODULE)
      $directories[] = LX_APPLICATION_ROOT . '/src/controllers/' . LX_MODULE;
    else
      $directories[] = LX_APPLICATION_ROOT . '/src/controllers';
    $directories[] = LX_APPLICATION_ROOT . '/src/filters';
    $directories[] = LX_APPLICATION_ROOT . '/tmp';
    $directories[] = LX_APPLICATION_ROOT . '/tmp/models';
  }

  //for each directory
  foreach ($directories as $directory)
  {
    $filename = $directory . '/' . $class_name . '.php';

    //echo $filename;
    //see if the file exsists
    if (file_exists($filename))
    {
      require_once ($filename);
      return ;
    }
  }
}

?>