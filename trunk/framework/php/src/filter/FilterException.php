<?php

class FilterException extends Exception
{
  private $filter	= NULL;

  public function getFilter()
  {
    return ($this->filter);
  }

  public function FilterException($myFilter, $myError = "")
  {
    parent::__construct($myError);

    $this->filter = $myFilter;
  }
}

?>