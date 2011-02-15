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
  static public function scaffold($my_model,
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
    $node = LX::getResponse()->getDocument()->createElement(get_class($this));

    foreach ($this as $property => $flags)
    {
      if (is_string($this->$property))
      {
	$prop_node = LX::getResponse()->getDocument()->createElement($property);

	$prop_node->nodeValue = $this->$property;
	$node->appendChild($prop_node);
      }
      else
      {
	$node->setAttribute($property, $this->$property);
      }
    }

    return ($node);
  }

//   abstract public function save();
//   abstract public function update();
}

?>
