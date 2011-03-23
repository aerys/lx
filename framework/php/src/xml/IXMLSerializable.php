<?php

interface IXMLSerializable
{
  public function toXML($exclude        = null,
                        $noRoot         = false);
}

?>