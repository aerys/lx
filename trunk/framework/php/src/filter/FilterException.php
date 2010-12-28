<?php

class FilterException extends Exception
{
  private $filter	= NULL;

  public function getFilter()		{return ($this->filter);}

  public function FilterException($myFilter)
  {
    parent::__construct();

    $this->filter = $myFilter;
  }

}

?>