<?php

class MySQLQuery extends AbstractQuery
{
  const ARGUMENT_PREFIX	= ':';

  protected $database	= NULL;
  protected $request	= '';
  protected $arguments	= array();

  public function toString()	{return ($this->request);}

  public function MySQLQuery($my_database,
			     $my_request)
  {
    $this->database  = $my_database;
    $this->request = $my_request;

    $args = array();
    preg_match_all('/:([A-Za-z0-9_]+)/', $this->request, $args);

    foreach ($args[0] as $i => $arg)
    {
      $pos = strpos($this->request, $arg);
      $hash = self::ARGUMENT_PREFIX . md5(rand());

      $this->arguments[$args[1][$i]] = $hash;
      $this->request = substr_replace($this->request, $hash, $pos, strlen($arg));
    }
  }

  public function setInteger($my_arg,
			     $my_value)
  {
    // sql injection fix
    $my_value = (int)$my_value;

    $this->request = str_replace($this->arguments[$my_arg],
				 $my_value,
				 $this->request);

    return ($this);
  }

  public function setFloat($my_arg,
			   $my_value)
  {
    // sql injection fix
    $my_value = (float)$my_value;

    $this->request = str_replace($this->arguments[$my_arg],
				 $my_value,
				 $this->request);

    return ($this);
  }

  public function setString($my_arg,
			    $my_value)
  {
    // sql injections fix
    $my_value = $this->database->escapeString($my_value);

    $this->request = str_replace($this->arguments[$my_arg],
				 "'" . $my_value . "'",
				 $this->request);

    return $this;
  }

  public function setBoolean($my_arg,
			     $my_value)
  {
    $my_value = (int)$my_value ? 1 : 0;

    $this->request = str_replace($this->arguments[$my_arg],
				 $my_value,
				 $this->request);

    return $this;
  }
}

?>