<?php

abstract class AbstractModel
{
  const FLAG_DEFAULT	= 0;
  const FLAG_UPDATE	= 1;

  private $database	= NULL;
  private $flags	= self::FLAG_DEFAULT;

  public function getDatabase()		{return ($this->database);}

  public function setDatabase($my_db)	{$this->database = $my_db;}

  /* CONSTRUCTOR */
  public function AbstractModel($my_cfg)
  {
    $this->setDatabase(DatabaseFactory::create($my_cfg));
  }

  /* METHODS */
  public static function scaffold($my_model,
				  $my_backend,
				  $my_output)
  {
    $xml = new DOMDocument();
    $xml->load($my_model);

    $xsl = new DOMDocument();
    $xsl->load($my_backend);

    $processor = new XSLTProcessor();
    $processor->importStyleSheet($xsl);
    $processor->transformToURI($xml, $my_output);
  }

  public function loadArray($my_data)
  {
    foreach ($my_data as $name => $value)
      $this->$name = $value;
  }

  public function __get($my_property)
  {
    return ($this->$my_property);
  }

  public function __set($my_property, $my_value)
  {
    if ($this->$my_property != $my_value)
    {
      $this->$my_property = $my_value;
      $this->flags |= self::FLAG_UPDATE;
    }
  }

  public function serialize()
  {
    $rClass	= new ReflectionClass(get_class($this));
    $className  = strtolower($rClass->getName());
    $xml	= '<' . $className . '>';
    $properties = $rClass->getProperties();

    foreach ($properties as $property)
    {
      if ($property->isProtected())
      {
	$propertyName = $property->getName();

	$xml .= '<' . $propertyName . '>' . $this->$propertyName
	  . '</' . $propertyName . '>';
      }
    }

    $xml .= '</' . $className . '>';

    return ($xml);
  }

//   abstract public function save();
//   abstract public function update();
}

?>
