<?php

abstract class XMLSerializable implements IXMLSerializable
{
  abstract protected function getProperties();

  public function toXML($exclude	= null,
		        $noRoot         = false)
  {
    return XML::serializeObject($this, $exclude, $noRoot);
  }

  public function __toString()
  {
    return $this->toXML();
  }
}

?>