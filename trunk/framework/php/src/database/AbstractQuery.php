<?php

abstract class AbstractQuery
{
  abstract public function setInteger($arg,
				      $value);
  abstract public function setString($arg,
				     $value);
  abstract public function setBoolean($arg,
				      $value);

  abstract public function setFloat($arg,
				    $value);

  abstract public function getQueryString();
}

?>