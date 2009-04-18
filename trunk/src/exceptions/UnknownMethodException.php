<?php

class UnknownMethodException extends Exception
{

  public function UnknownMethodException($my_method, $my_arguments)
  {
    parent::__construct('Unknown method ' . $my_method . '(' .
			implode(', ', $my_arguments) . ')');
  }

}

?>