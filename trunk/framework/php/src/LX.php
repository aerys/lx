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
                                                '/xml',
						'/response');

  static private $app_directories	= array('/src',
						'/src/models',
						'/src/controllers',
						'/src/filters',
						'/bin',
						'/bin/models');

  static private $extensionToMime       = array('css'   => 'text/css',
                                                'xml'   => 'text/xml',
                                                'xsl'   => 'text/xsl',
                                                'png'   => 'image/png',
                                                'jpg'   => 'image/jpg',
                                                'js'    => 'text/javascript',
                                                'swf'   => 'application/x-shockwave-flash');

  static public function setResponse($my_response)	{self::$response = $my_response;}
  static public function getResponse()			{return (self::$response);}

  static public function getDatabaseConfiguration($my_name)
  {
    global $_LX;

    return isset($_LX['databases'][$my_name])
           ? $_LX['databases'][$my_name]
           : null;
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
    $pattern = '/^[a-z]+:\/\/.*$/s';
    $external = !!preg_match($pattern, $url);

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

  static public function debug($msg)
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
    if (($pos = strpos($url, '?')) !== false)
      $url = substr($url, 0, $pos);
    if (LX_DOCUMENT_ROOT != '/'
        && ($pos = strpos($url, LX_DOCUMENT_ROOT)) !== false)
      $url = substr($url, $pos + strlen(LX_DOCUMENT_ROOT));

    if ((preg_match('#^/views/(.*)\.(xsl|xml)$#', $url)
         && file_exists($filename = LX_APPLICATION_ROOT . '/src' . $url))
        || (file_exists($filename = LX_APPLICATION_ROOT . '/public' . $url)
            && !is_dir($filename)))
    {
      $extension = substr($url, strrpos($url, '.') + 1);
      $lastModified = filemtime($filename);

      if (isset(self::$extensionToMime[$extension]))
        header('Content-Type: ' . self::$extensionToMime[$extension]);

      if (isset($_SERVER['HTTP_IF_MODIFIED_SINCE'])
          && strtotime($_SERVER['HTTP_IF_MODIFIED_SINCE']) >= $lastModified)
      {
        if (php_sapi_name() == 'CGI')
          header('Status: 304 Not Modified');
        else
          header('HTTP/1.0 304 Not Modified');
      }
      else
      {
        header('Cache-Control: max-age=' . LX_HTTP_CACHE . ', must-revalidate');
        header('Last-Modified: ' . gmdate("D, d M Y H:i:s\G\M\T", $lastModified));
        header('Content-Length: ' . filesize($filename));

        readfile($filename);
      }
    }
    else
    {
      Dispatcher::get()->dispatchHTTPRequest($url, $get, $post);
    }
  }

  static public function print_r($myVariable)
  {
    $str = htmlentities(print_r($myVariable, true));

    return $str;
  }
}

?>