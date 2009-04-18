<?php

function __autoload($class_name)
{
  //class directories
  $directories = array(LX_SRC,
		       LX_SRC . '/exceptions',
		       LX_SRC . '/database',
		       LX_SRC . '/database/mysql');

  if (defined('LX_APPLICATION'))
  {
    $directories[] = LX_APPLICATION . '/src/models';
    $directories[] = LX_APPLICATION . '/src/controllers';
    $directories[] = LX_APPLICATION . '/src/filters';
    $directories[] = LX_APPLICATION . '/tmp';
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