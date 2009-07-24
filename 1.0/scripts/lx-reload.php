<?php

require_once ($argv[1] . '/tmp/lx-project.php');
require_once ('../misc/lx-config.php');

// erase the content of the LX_TMP directory
$dh = @opendir(LX_APPLICATION . '/tmp');
while (($file = readdir($dh)))
  if ($file[0] != '.' && $file != 'lx-project.php')
    unlink(LX_APPLICATION . '/tmp/' . $file);

// regenerate every model
$dh = @opendir(LX_APPLICATION . '/models');
while (($file = readdir($dh)))
{
  if ($file[0] != '.')
  {
    $class_name = substr($file, 0, strpos($file, '.'));

    AbstractModel::scaffold(LX_APPLICATION . '/models/' . $file,
			    LX_XSL . '/lx-php-model.xsl',
			    LX_APPLICATION . '/tmp/' . $class_name . '.php');
  }
}

?>