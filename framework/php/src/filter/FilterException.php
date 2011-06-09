<?php

class FilterException extends Exception
{
  private $filter	= null;
  private $data		= null;

  public function getFilter() 	{ return $this->filter;}
  public function getData()  	{ return $this->data;}

  public function FilterException($filter, $error = "", $data = null)
  {
    parent::__construct($error);

    $this->filter = $filter;
    $this->data = $data;
  }
}

?>