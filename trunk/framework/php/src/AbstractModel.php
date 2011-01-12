<?php

abstract class AbstractModel extends XMLSerializable
{
  const FLAG_DEFAULT	= 0;
  const FLAG_UPDATE	= 1;

  protected $flags	= self::FLAG_DEFAULT;

  /* CONSTRUCTOR */
  public function AbstractModel($data = null)
  {
    if ($data)
      $this->loadArray($data);
  }

  /* METHODS */
  public static function scaffold($model,
				  $backend,
				  $output)
  {
    $xml = new DOMDocument();
    $xml->load($model);

    $xsl = new DOMDocument();
    $xsl->load($backend);

    $processor = new XSLTProcessor();
    $processor->importStyleSheet($xsl);
    $processor->transformToURI($xml, $output);
  }

  public function loadArray($data)
  {
    $class = get_class($this);

    foreach ($this->getProperties() as $name)
      if (isset($data[$name]))
        $this->$name = $data[$name];
  }

  /*public function loadXML($filename)
  {
    $doc = new DOMDocument();
    $doc->load($filename);


  }

  public function saveXML($filename = null)
  {
    $xml = XML::serialize($this);

    if (!$filename)
      return $xml;

    $doc = new DOMDocument();

    $fragment = $doc->createDocumentFragment();
    $fragment->appendXML($xml);

    // FIXME: open file and save XML
    }*/

  public function __get($propertyName)
  {
    return $this->$propertyName;
  }

  public function __set($propertyName, $value)
  {
    if ($this->$property != $value)
    {
      $this->$property = $value;
      $this->flags |= self::FLAG_UPDATE;
    }
  }

  public function __call($p, $a)
  {
    throw new UnknownMethodException(get_class($this) . '::' . $p, $a);
  }
}

?>
