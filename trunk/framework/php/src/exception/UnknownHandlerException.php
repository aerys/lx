<?php

class UnknownHandlerException extends ErrorException
{

  public function UnknownHandlerException($my_handler)
  {
    parent::__construct('Unknown handler \'' . $my_handler . '\'');
  }

}

?>