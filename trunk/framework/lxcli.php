<?php

define('LX_HOME',       substr($argv[0], 0, strrpos($argv[0], '/') + 1));
define('N',             "\n");
define('T',             "\t");
define('SYS',           $argv[1]);
define('CURRENT',       $argv[2]);
define('DEBUG',         false);

function copy_dir($src, $dst, $mkdir = false)
{
  $dir = opendir($src);
  if ($mkdir) { @mkdir($dst); }

  while(false !== ($file = readdir($dir)))
  {
    if (($file != '.') && ($file != '..'))
    {
      if (is_dir($src . '/' . $file))
        copy_dir($src  .  '/'  . $file, $dst . '/' . $file, true);
      else
        copy($src . '/' . $file, $dst . '/' . $file);
    }
  }

  closedir($dir);
}

function rm_rf($dir)
{
  if (is_dir($dir))
  {
    $objects = scandir($dir);

    foreach ($objects as $object)
    {
      if ($object != '.' && $object != '..')
      {
        if (filetype($dir . '/' . $object) == 'dir')
          rm_rf($dir . '/' . $object);
        else
          unlink($dir . '/' . $object);
      }
    }

    reset($objects);
    rmdir($dir);
  }
}

function copy_ext($src, $ext, $dst)
{
  if (!is_dir($src)) { die('ERROR: ' . $src); }

  $dir = opendir($src);

  while(false !== ($file = readdir($dir)))
  {
    if (!is_dir($file) && ($file != '.') && ($file != '..') && (substr($file, -strlen($ext)) == $ext))
    {
      copy($src . '/' . $file, $dst . '/' . $file);
    }
  }

  closedir($dir);
}

function create($path, $name)
{
  $out = T . 'directory: ' . $path;
  if (!is_dir($path))
    die('\'' . $path . '\' is not a valid directory.');

  @mkdir($path . '/' . $name);
  @mkdir($path . '/' . $name . '/bin');
  @mkdir($path . '/' . $name . '/bin/models');

  copy_dir(LX_HOME . '../project', $path . '/' . $name);

  @mkdir($path . '/' . $name . '/src/models');
  @mkdir($path . '/' . $name . '/lib');

  if (SYS === 'win')
  {
    @mkdir($path . '/' . $name . '/lib/lx');

    //windows does not support any ln -s so we have to copy all the lib right into the project
    copy_dir(LX_HOME, $path . '/' . $name . '/lib/lx');
    rm_rf($path . '/' . $name . '/lib/lx/project');

    copy_ext(LX_HOME . 'xsl/src', 'xsl', $path . '/' . $name . '/src/views');
  }
  else //any other unix based shell
  {
    exec('ln -s ' . LX_HOME . ' ' . $path . '/' . $name . '/lib/lx');
  }

  return $out;
}

function update($feature)
{
  $out = '';

  switch($feature)
  {
    case 'lib':
      $out = lib();
      break;

    case 'config':
      $out = config();
      break;

    case 'models':
      $out = models();
      break;

    case 'all':
      $out = config();
      $out .= models();
      break;

    default:
      die('unknown parameter ' . $feature);
      break;
  }

  return $out;
}

function lib()
{
  $out = 'This undocumented feature is windows only';
  copy_dir(LX_HOME, CURRENT . '/lib/lx');
}

function config()
{

  if (SYS == 'win') {  }
  else
  {  }

  $out = exec('php --rc XSLTProcessor');
  if (substr($out, 0, 1) == 'E')
    die('You must enable xslt extension in your php.ini');

  $out = exec('php lib/lx/php/src/scripts/lx-project.php '
              . CURRENT . '/lx-project.xml > bin/lx-project.php');
  return $out;
}

function models()
{
  $out = '';
  $models = array();
  $dir = opendir(CURRENT . '/src/models');

  while(false !== ($file = readdir($dir)))
    if (($file != '.') && ($file != '..') && (substr($file, -3, 3) == 'xml'))
      array_push($models, substr($file, 0, -4));

  closedir($dir);

  foreach($models as $model)
  {
    $cmd = 'php -f lib/lx/php/src/scripts/lx-orm.php src/models/'
           . $model . '.xml lx-php-orm.xsl > bin/models/'
           . $model . '.php';

    $out = exec($cmd);
  }

  return $out;
}

function help()
{
  return 'Usage: /lxcli.sh [action]' . N
    . 'Actions:' . N
    . '  create %project' . T . T . 'Deploy a new project named %project in your current directory' . N
    . '  create %project in %dir' . T . 'Deploy a new project named %project in the %dir directory' . N
    . '  update' . T . T . T. 'Update all project files (configuration and models)' . N
    . '  update config' . T . T . T . 'Update configuration files only' . N
    . '  update models' . T . T . T . 'Update models only' . N
    . '  help' . T . T . T . T . 'Display this message' . N;
}

if (DEBUG)
  print_r($argv);

if ($argc < 4)
  die(help());

switch($argv[3])
{
  case 'create':
    if (isset($argv[4]))
    {
      $name = $argv[4];
      $path = $argv[2];

      if (isset($argv[5]) && $argv[5] == 'in')
      {
        if (isset($argv[6]))
          $path = $argv[6];
        else
          die('error');
      }
      else if (isset($argv[5]))
        die('error');

      die(create($path, $name));

    }
    else
      die('error');
    break;

  case 'create-in':
    die(create(isset($argv[4]) ? $argv[4] : ''));
    break;

  case 'update':
    die(update((isset($argv[4]) ? $argv[4] : 'all' )));
    break;

  case 'help':
  default:
    die(help());
  break;
}

?>