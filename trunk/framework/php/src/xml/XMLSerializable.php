<?php

class XMLSerializable
{
  protected function getProperties()
  {
    throw new ErrorException();
  }

  public function serialize($myExclude	= null,
			    $myEscape	= null,
			    $myNoRoot	= false)
  {
    $class      = get_class($this);
    $rootName   = strtolower($class);
    $xml	= $myNoRoot ? '' : '<' . $rootName . '>';

    foreach ($this->getProperties() as $property)
    {
      if (!$myExclude || false === array_search($property, $myExclude, true))
      {
	$xml .= '<' . $property . '>';

	if ($myEscape && false !== array_search($property, $myEscape, true))
	  $xml .= '<![CDATA[' . $this->$property . ']]>';
	else
	  $xml .= $this->$property;

	$xml .= '</' . $property . '>';
      }
    }

    if (!$myNoRoot)
      $xml .= '</' . $rootName . '>';

    return $xml;
  }

  public function __toString()
  {
    return $this->serialize();
  }
}

?>