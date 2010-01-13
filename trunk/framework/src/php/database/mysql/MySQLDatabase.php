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

    return ($this->mysqli->insert_id);
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

  public function performQuery($my_query)
  {
    $this->connect();

    $sql_str = $my_query->toString();

    LX::appendDebugMessage('<mysql-query>' . $sql_str . '</mysql-query>');

    $result = $this->mysqli->query($sql_str);

    if (!$result)
      throw new ErrorException($this->mysqli->error);

    if (true === $result)
      return (true);

    $response = array();
    while ($row = $result->fetch_assoc())
      $response[] = $row;

    return ($response);
  }

  public function escapeString($my_str)
  {
    $this->connect();

    if (get_magic_quotes_gpc())
      $my_str = stripslashes($my_str);

    return ($this->mysqli->real_escape_string($my_str));
  }

}

?>
