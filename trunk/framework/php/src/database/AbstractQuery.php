<?php

abstract class AbstractQuery
{
  abstract public function setInteger($my_arg,
				      $my_value);
  abstract public function setString($my_arg,
				     $my_value);
  abstract public function setBoolean($my_arg,
				      $my_value);

  abstract public function setFloat($my_arg,
				    $my_value);

  abstract public function toString();
}

?>