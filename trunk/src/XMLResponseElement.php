<?php

class XMLResponseElement
{

  private $fragment;

  public function getFragment()  {return ($this->fragment);}

  public function XMLResponseElement()
  {
    $this->fragment = LX::getResponse()->getDocument()->createDocumentFragment();
  }

  protected function appendXML($my_data)
  {
    $this->fragment->appendXML($my_data);
  }

  protected function appendChild($my_child)
  {
    $this->fragment->appendChild($my_child);
  }

}

?>