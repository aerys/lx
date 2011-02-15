<?php

class MySQLQuery extends AbstractQuery
{
  const ARGUMENT_PREFIX	= ':';

  protected $database	= NULL;
  protected $request	= '';

  public function toString()	{return ($this->request);}

  public function MySQLQuery($my_database,
			     $my_request)
  {
    $this->database  = $my_database;
    $this->request = $my_request;
  }

  public function setInteger($my_arg,
			     $my_value)
  {
    // sql injection fix
    $my_value = (int)$my_value;

    $this->request = str_replace(self::ARGUMENT_PREFIX . $my_arg,
				 $my_value,
				 $this->request);
  }

  public function setString($my_arg,
			    $my_value)
  {
    // sql injections fix
    $my_value = $this->database->escapeString($my_value);

    $this->request = str_replace(self::ARGUMENT_PREFIX . $my_arg,
				 "'" . $my_value . "'",
				 $this->request);
  }

  public function setBoolean($my_arg,
			     $my_value)
  {
    $my_value = (int)$my_value ? 1 : 0;

    $this->request = str_replace(self::ARGUMENT_PREFIX . $my_arg,
				 $my_value,
				 $this->request);
  }
}

?>