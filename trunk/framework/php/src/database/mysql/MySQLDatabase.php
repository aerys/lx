<?php

class MySQLDatabase extends AbstractDatabase
{
  protected $host		= '';
  protected $user		= '';
  protected $password		= '';
  protected $database		= '';
  protected $isConnected	= false;

  protected $mysqli		= NULL;

  public function MySQLDatabase($my_cfg)
  {
    $this->host = $my_cfg['host'];
    $this->user = $my_cfg['user'];
    $this->password = $my_cfg['password'];
    $this->database = $my_cfg['name'];
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

    $this->mysqli = new mysqli($this->host,
			       $this->user,
			       $this->password,
			       $this->database);

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

  public function performQuery($my_query, $type = null)
  {
    $this->connect();

    $sql_str = $my_query->toString();

    $time = LX_DEBUG ? microtime() : 0;
    $result = $this->mysqli->query($sql_str);
    if (LX_DEBUG)
      LX::appendDebugMessage('<mysqlQuery time="' . ((microtime() - $time) * 1000)
			     . '"><![CDATA[' . $sql_str . ']]></mysqlQuery>');

    if (!$result)
      throw new ErrorException($this->mysqli->error);

    if (true === $result)
      return true;

    $response = array();
    while (($row = $result->fetch_assoc()))
      $response[] = $type ? new $type($row) : $row;

    return $response;
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
