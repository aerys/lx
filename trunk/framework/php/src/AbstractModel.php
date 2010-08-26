<?php

abstract class AbstractModel
{
  const FLAG_DEFAULT	= 0;
  const FLAG_UPDATE	= 1;

  private $flags	= self::FLAG_DEFAULT;

  /* CONSTRUCTOR */
  public function AbstractModel($myData = null)
  {
    if ($myData)
      $this->loadArray($myData);
  }

  /* METHODS */
  public static function scaffold($myModel,
				  $myBackend,
				  $myOutput)
  {
    $xml = new DOMDocument();
    $xml->load($myModel);

    $xsl = new DOMDocument();
    $xsl->load($myBackend);

    $processor = new XSLTProcessor();
    $processor->importStyleSheet($xsl);
    $processor->transformToURI($xml, $myOutput);
  }

  public function loadArray($myData)
  {
    $class      = get_class($this);
    $properties = $class::$__properties__;

    foreach ($properties as $name)
      if (isset($myData[$name]))
        $this->$name = $myData[$name];
  }

  public function __get($myProperty)
  {
    return $this->$myProperty;
  }

  public function __set($myProperty, $myValue)
  {
    if ($this->$myProperty != $myValue)
    {
      $this->$myProperty = $myValue;
      $this->flags |= self::FLAG_UPDATE;
    }
  }

  public function __call($p, $a)
  {
    throw new UnknownMethodException(get_class($this) . '::' . $p, $a);
  }

  public function serialize($myExclude	= null,
			    $myEscape	= null,
			    $myNoRoot	= false)
  {
    $class      = get_class($this);
    $rootName   = strtolower($class);
    $properties = $class::$__properties__;
    $xml	= $myNoRoot ? '' : '<' . $rootName . '>';

    foreach ($properties as $property)
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

    return ($xml);
  }

  public function __toString()
  {
    return $this->serialize();
  }

//   abstract public function save();
//   abstract public function update();
}

?>
