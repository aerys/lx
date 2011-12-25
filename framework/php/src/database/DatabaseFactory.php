<?php

class DatabaseFactory
{
  static protected $databases = NULL;

  static public function create($cfgName)
  {
    if (!self::$databases)
      self::$databases = array();

    if (!array_key_exists($cfgName, self::$databases))
    {
      $cfg = LX::getDatabaseConfiguration($cfgName);
      $new_db = NULL;

      if (!$cfg)
        throw new ErrorException("Database '$cfgName' has no configuration associated.");

      switch ($cfg['type'])
      {
        case 'mysql':
        default :
          $new_db = new MySQLDatabase($cfg);
          break;
      }

      self::$databases[$cfgName] = $new_db;
    }

    return (self::$databases[$cfgName]);
  }
}

?>
