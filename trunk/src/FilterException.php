<?php

class FilterException extends Exception
{
  private $filter	= NULL;
  private $view		= NULL;
  private $layout	= NULL;
  private $mMedia	= NULL;

  public function getView()	{return ($this->view);}
  public function getLayout()	{return ($this->layout);}
  public function getMedia()	{return ($this->media);}

  public function FilterException($my_filter,
				  $my_view	= NULL,
				  $my_layout	= NULL,
				  $my_media	= NULL)
  {
    parent::__construct();

    $this->filter = $my_filter;
    $this->view = $my_view;
    $this->layout = $my_layout;
    $this->media = $my_media;
  }

}

?>