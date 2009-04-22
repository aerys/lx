<?php

class UnknownControllerException extends Exception
{

  public function UnknownControllerException($my_controler)
  {
    parent::__construct('Unknown controller \'' . $my_controler . '\'');
  }

}

?>