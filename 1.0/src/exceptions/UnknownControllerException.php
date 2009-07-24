<?php

class UnknownControllerException extends ErrorException
{

  public function UnknownControllerException($my_controler)
  {
    parent::__construct('Unknown controller \'' . $my_controler . '\'');
  }

}

?>