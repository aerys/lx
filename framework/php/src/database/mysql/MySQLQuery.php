<?php

class MySQLQuery extends AbstractQuery
{
  const ARGUMENT_PREFIX	= ':';
  const KEY_LENGTH      = 8;

  protected $database	= NULL;
  protected $request	= '';
  protected $arguments	= array();

  public function __toString()          { return $this->request; }
  public function getQueryString()      { return $this->request; }

  public function MySQLQuery($database,
			     $request)
  {
    $this->database  = $database;
    $this->request = $request;

    $args = array();
    preg_match_all('/:([A-Za-z0-9_]+)/', $this->request, $args);

    foreach ($args[0] as $i => $arg)
    {
      if (empty($this->arguments[$args[1][$i]]))
      {
        $pos = strpos($this->request, $arg);
        $hash = substr(self::ARGUMENT_PREFIX . md5(rand()), self::KEY_LENGTH);

        $this->arguments[$args[1][$i]] = $hash;
        $this->request = str_replace($arg, $hash, $this->request);
      }
    }
  }

  public function setInteger($myArg,
			     $myValue)
  {
    if (is_array($myValue))
    {
      for ($i = 0; $i < count($myValue); ++$i)
        $myValue[$i] = (int)$myValue[$i];

      return $this->setTuple($myArg, $myValue);
    }

    $myValue = (int)$myValue;

    $this->request = str_replace($this->arguments[$myArg],
				 $myValue,
				 $this->request);

    return $this;
  }

  public function setFloat($myArg,
			   $myValue)
  {
    if (is_array($myValue))
    {
      for ($i = 0; $i < count($myValue); ++$i)
        $myValue[$i] = (float)$myValue[$i];

      return $this->setTuple($myArg, $myValue);
    }

    $myValue = (float)$myValue;

    $this->request = str_replace($this->arguments[$myArg],
				 $myValue,
				 $this->request);

    return $this;
  }

  public function setString($myArg,
			    $myValue)
  {
    if (is_array($myValue))
    {
      for ($i = 0; $i < count($myValue); ++$i)
        $myValue[$i] = '\'' . $this->database->escapeString($myValue[$i]) . '\'';

      return $this->setTuple($myArg, $myValue);
    }

    $myValue = $this->database->escapeString($myValue);

    $this->request = str_replace($this->arguments[$myArg],
				 '\'' . $myValue . '\'',
				 $this->request);

    return $this;
  }

  public function setBoolean($myArg,
			     $myValue)
  {
    if (is_array($myValue))
    {
      for ($i = 0; $i < count($myValue); ++$i)
        $myValue[$i] = (boolean)$myValue[$i] ? 'true' : 'false';

      return $this->setTuple($myArg, $myValue);
    }

    $myValue = (boolean)$myValue ? 'true' : 'false';

    $this->request = str_replace($this->arguments[$myArg],
				 $myValue,
				 $this->request);

    return $this;
  }

  private function setTuple($myArg,
                            $myValue)
  {
    $value = '(';

    for ($i = 0; $i < count($myValue); ++$i)
      $value .= (!!$i ? ', ' : '') . $myValue[$i];

    $value .= ')';

    $this->request = str_replace($this->arguments[$myArg],
				 $value,
				 $this->request);

    return $this;
  }
}

?>