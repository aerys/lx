<?php

class MySQLDatabase extends AbstractDatabase
{
  protected $host		= '';
  protected $user		= '';
  protected $password		= '';
  protected $database		= '';
  protected $isConnected	= false;
  protected $cd			= 0;

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

    return (mysqli_insert_id($this->cd));
  }

  public function connect()
  {
    if ($this->isConnected)
      return ;

    // connect to the mysql server
    $this->cd = mysqli_connect($this->host,
			       $this->user,
			       $this->password,
			       $this->database);

    //mysqli_select_db($this->cd, $this->database);

    $this->isConnected = true;
  }

  public function disconnect()
  {
    mysqli_disconnect($this->cd);
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
    $result = mysqli_query($this->cd, $sql_str);

    if (!$result)
      throw new ErrorException(mysqli_error($this->cd));

    if (true === $result)
      return (true);

    $response = array();
    while ($row = mysqli_fetch_assoc($result))
      $response[] = $row;

    return ($response);
  }

  public function escapeString($my_str)
  {
    $this->connect();

    if (get_magic_quotes_gpc())
      $my_str = stripslashes($my_str);

    return (mysqli_real_escape_string($this->cd, $my_str));
  }
}

?>
