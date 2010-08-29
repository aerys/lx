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

  public function setInteger($myArg,
			     $myValue)
  {
    // sql injection fix
    if (is_array($myValue))
    {
      $value = '(';

      for ($i = 0; $i < count($myValue); ++$i)
        $value .= (!!$i ? ', ' : '') . (int)$myValue[$i];

      $value .= ')';
    }
    else
    {
      $value = (int)$myValue;
    }


    $this->request = str_replace($this->arguments[$myArg],
				 $value,
				 $this->request);

    return $this;
  }

  public function setFloat($myArg,
			   $myValue)
  {
    // sql injection fix
    if (is_array($myValue))
    {
      $value = '(';

      for ($i = 0; $i < count($myValue); ++$i)
        $value .= (!!$i ? ', ' : '') . (float)$myValue[$i];

      $value .= ')';
    }
    else
    {
      $value = (float)$myValue;
    }

    $this->request = str_replace($this->arguments[$myArg],
				 $value,
				 $this->request);

    return $this;
  }

  public function setString($myArg,
			    $myValue)
  {
    // sql injection fix
    if (is_array($myValue))
    {
      $value = '(';

      for ($i = 0; $i < count($myValue); ++$i)
        $value .= (!!$i ? ', ' : '')
                    . $this->database->escapeString($myValue[$i]);

      $value .= ')';
    }
    else
    {
      $value = $this->database->escapeString($myValue);
    }

    $this->request = str_replace($this->arguments[$myArg],
				 "'" . $value . "'",
				 $this->request);

    return $this;
  }

  public function setBoolean($myArg,
			     $myValue)
  {
    if (is_array($myValue))
    {
      $value = '(';

      for ($i = 0; $i < count($myValue); ++$i)
        $value .= (!!$i ? ', ' : '') . (boolean)$myValue[$i];

      $value .= ')';
    }
    else
    {
      $value = (boolean)$myValue;
    }

    $this->request = str_replace($this->arguments[$myArg],
				 $value,
				 $this->request);

    return $this;
  }
}

?>