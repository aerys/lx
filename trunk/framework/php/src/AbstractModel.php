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
    foreach ($myData as $name => $value)
      $this->$name = $value;
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
    $rClass	= new ReflectionClass(get_class($this));
    $className  = strtolower($rClass->getName());
    $xml	= $myNoRoot ? '' : '<' . $className . '>';
    $properties = $rClass->getProperties();

    foreach ($properties as $property)
    {
      $propertyName = $property->getName();

      if ($property->isProtected()
	  && (!$myExclude || false === array_search($propertyName, $myExclude, true)))
      {
	$xml .= '<' . $propertyName . '>';

	if ($myEscape && false !== array_search($propertyName, $myEscape, true))
	  $xml .= '<![CDATA[' . $this->$propertyName . ']]>';
	else
	  $xml .= $this->$propertyName;

	$xml .= '</' . $propertyName . '>';
      }
    }

    if (!$myNoRoot)
      $xml .= '</' . $className . '>';

    return ($xml);
  }

//   abstract public function save();
//   abstract public function update();
}

?>
