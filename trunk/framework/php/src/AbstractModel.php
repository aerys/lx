<?php

abstract class AbstractModel extends XMLSerializable
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

    foreach ($this->getProperties() as $name)
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
}

?>
