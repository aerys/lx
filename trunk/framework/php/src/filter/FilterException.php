<?php

class FilterException extends Exception
{
  private $filter	= NULL;
  private $redirection	= NULL;

  public function getFilter()		{return ($this->filter);}
  public function getRedirection()	{return ($this->redirection);}

  public function FilterException($myFilter,
				  $myRedirection	= NULL)
  {
    parent::__construct();

    $this->filter = $myFilter;
    $this->redirection = $myRedirection;
  }

}

?>