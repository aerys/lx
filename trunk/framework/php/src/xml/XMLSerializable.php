<?php

class XMLSerializable
{
  protected function getProperties()
  {
    throw new ErrorException();
  }

  public function serialize($exclude	= null,
			    $noRoot	= false)
  {
    return XML::serializeObject($this, $exclude, $noRoot);
  }

  public function __toString()
  {
    return $this->serialize();
  }
}

?>