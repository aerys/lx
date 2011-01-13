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

  public function copy($model)
  {
    foreach ($this->getProperties() as $name)
      $this->$name = $model->$name;
  }

  public function loadXML($filename)
  {
    $cache = Cache::getCache();
    $object = $cache->get($filename);

    if ($object)
    {
      $this->copy($object);
    }
    else
    {
      $xml = simplexml_load_file($filename);

      foreach ($xml->children() as $child)
      {
        $nodeName = $child->getName();
        $l = strlen($nodeName) + 2;
        $xml = $child->asXML();

        $this->$nodeName = substr($xml, $l, strlen($xml) - ($l * 2 + 1));
      }

      $cache->set($filename, $this);
    }
  }

  public function saveXML($filename = null)
  {
    $xml = XML::serialize($this);

    if (!$filename)
      return $xml;

    $doc = new DOMDocument('1.0', 'utf-8');

    $fragment = $doc->createDocumentFragment();
    $fragment->appendXML($xml);
    $doc->appendChild($fragment);

    $doc->save($filename);
  }

  public function __get($propertyName)
  {
    return $this->$propertyName;
  }

  public function __set($propertyName, $value)
  {
    if ($this->$propertyName != $value)
    {
      $this->$propertyName = $value;
      $this->flags |= self::FLAG_UPDATE;
    }
  }

  public function __call($p, $a)
  {
    throw new UnknownMethodException(get_class($this) . '::' . $p, $a);
  }
}

?>
