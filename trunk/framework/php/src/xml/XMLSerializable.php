<?php

abstract class XMLSerializable
{
  abstract protected function getProperties();

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