<?php

new Cache(Cache::DEFAULT_CACHE_NAME);

class Cache
{
  const DEFAULT_CACHE_NAME  = 'lx_default_cache';

  private static $caches    = array();

  private $host      = null;
  private $port      = 11211;

  private $enabled   = false;
  private $memcache  = null;
  private $connected = false;

  public static function getCache($name = self::DEFAULT_CACHE_NAME)
  {
    return isset(self::$caches[$name]) ? self::$caches[$name]
                                       : null;
  }

  public function Cache($name,
                        $host = '127.0.0.1',
                        $port = 11211)
  {
    if (!class_exists('Memcache'))
      return ;

    self::$caches[$name] = $this;
    $this->host = $host;
    $this->port = $port;

    $this->memcache = new Memcache();
    $this->enabled = true;
  }

  private function connect()
  {
    if ($this->enabled && !$this->connected)
    {
      try
      {
        $this->connected = $this->memcache->connect($this->host,
                                                    $this->port);
      }
      catch (Exception $e)
      {
        return false;
      }
    }

    return $this->connected;
  }

  public function get($key)
  {
    $time = microtime();
    $result = $this->connect() ? $this->memcache->get($key)
                               : null;

    $time = (microtime() - $time) * 1000.;
    LX::appendDebugMessage('<cache-get time="' . $time . '">'
                           . $key
                           . '</cache-get>');

    return $result;
  }

  public function set($key, $value, $ttl = 0, $compressed = false)
  {
    LX::appendDebugMessage('<cache-set ttl="' . $ttl . '">'
                          . $key
                          . '</cache-set>');

    return $this->connect()
           ? $this->memcache->set($key,
                                  $value,
                                  $compressed ? MEMCACHE_COMPRESSED : 0,
                                  $ttl)
           : false;
  }

  public function delete($key)
  {
    return $this->connect()
           ? $this->memcache->delete($key)
           : false;
  }

  public function flush()
  {
    return $this->connect()
           ? $this->memcache->flush()
           : false;
  }
}

?>