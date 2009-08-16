<?php

class FilterException extends Exception
{
  private $filter	= NULL;
  private $view		= NULL;
  private $layout	= NULL;
  private $template	= NULL;

  public function getFilter()	{return ($this->filter);}
  public function getView()	{return ($this->view);}
  public function getLayout()	{return ($this->layout);}
  public function getTemplate()	{return ($this->template);}

  public function FilterException($my_filter,
				  $my_template	= NULL,
				  $my_layout	= NULL,
				  $my_view	= NULL)


  {
    parent::__construct();

    $this->filter = $my_filter;
    $this->view = $my_view;
    $this->layout = $my_layout;
    $this->template = $my_template;
  }

}

?>