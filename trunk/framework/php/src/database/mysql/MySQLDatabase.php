<?php

class MySQLDatabase extends AbstractDatabase
{
  protected $host		= '';
  protected $user		= '';
  protected $password		= '';
  protected $database		= '';
  protected $encoding		= '';
  protected $isConnected	= false;

  protected $mysqli		= NULL;

  public function MySQLDatabase($my_cfg)
  {
    $this->host = $my_cfg['host'];
    $this->user = $my_cfg['user'];
    $this->database = $my_cfg['name'];

    if (array_key_exists('password', $my_cfg))
      $this->password = $my_cfg['password'];

    if (array_key_exists('encoding', $my_cfg))
      $this->encoding = $my_cfg['encoding'];
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

    $this->isConnected = true;
  }

  public function disconnect()
  {
    $this->mysqli->close();

    $this->isConnected = false;
  }

  public function createQuery($my_request)
  {
    return (new MySQLQuery($this, $my_request));
  }

  public function performQuery($my_query, $modelClass = null)
  {
    $this->connect();

    $sql_str = $my_query->getQueryString();

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

    return new ResultSet($response);
  }

  public function escapeString($my_str)
  {
    $this->connect();

    if (get_magic_quotes_gpc())
      $my_str = stripslashes($my_str);

    return $this->mysqli->real_escape_string($my_str);
  }

}

?>
