<?php

class MySQLDatabase extends AbstractDatabase
{
  protected $host		= '';
  protected $user		= '';
  protected $password		= '';
  protected $database		= '';
  protected $encoding		= 'utf8';
  protected $isConnected	= false;

  protected $mysqli		= NULL;

  public function MySQLDatabase($cfg)
  {
    $this->host = $cfg['host'];
    $this->user = $cfg['user'];
    $this->database = $cfg['name'];

    if (array_key_exists('password', $cfg))
      $this->password = $cfg['password'];

    if (array_key_exists('encoding', $cfg))
      $this->encoding = $cfg['encoding'];
  }

  public function getInsertId()
  {
    $this->connect();

    return $this->mysqli->insert_id;
  }

  public function connect()
  {
    if ($this->isConnected)
      return ;

    $time = microtime();
    $this->mysqli = new mysqli($this->host,
			       $this->user,
			       $this->password,
			       $this->database);

    if ($this->encoding)
      $this->mysqli->query("SET NAMES '".$this->encoding."'");

    if (LX_DEBUG)
    {
      LX::debug(XML::node('mysqlConnect',
                          null,
                          array('host'          => $this->host,
                                'user'          => $this->user,
                                'database'      => $this->database,
                                'time'          => ((microtime() - $time) * 1000))));
    }

    $this->isConnected = true;
  }

  public function disconnect()
  {
    $this->mysqli->close();

    $this->isConnected = false;
  }

  public function createQuery($request)
  {
    return new MySQLQuery($this, $request);
  }

  public function performQuery($query, $modelClass = null)
  {
    $this->connect();

    $sql_str = $query->getQueryString();

    $time = LX_DEBUG ? microtime() : 0;
    $result = $this->mysqli->query($sql_str);
    if (LX_DEBUG)
    {
      LX::debug(XML::node('mysqlQuery',
                          $sql_str,
                          array('time' => ((microtime() - $time) * 1000))));
    }

    if (!$result)
      throw new ErrorException($this->mysqli->error);

    if (true === $result)
      return true;

    $response = array();
    while (($row = $result->fetch_assoc()))
      $response[] = $modelClass ? new $modelClass($row) : $row;

    return count($response) ? new ResultSet($response) : null;
  }

  public function escapeString($str)
  {
    $this->connect();

    if (get_magic_quotes_gpc())
      $str = stripslashes($str);

    return $this->mysqli->real_escape_string($str);
  }

}

?>
