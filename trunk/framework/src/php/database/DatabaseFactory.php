<?php

class DatabaseFactory
{
  static protected $databases	= NULL;

  static public function create($my_cfgName)
  {
    if (!self::$databases)
      self::$databases = array();

    if (!isset(self::$databases[$my_cfgName]))
    {
      $cfg = LX::getDatabaseConfiguration($my_cfgName);
      $new_db = NULL;

      switch ($cfg['type'])
      {
	case 'mysql':
	default :
	  $new_db = new MySQLDatabase($cfg);
	  break;
      }

      self::$databases[$my_cfgName] = $new_db;
    }

    return (self::$databases[$my_cfgName]);
  }
}

?>