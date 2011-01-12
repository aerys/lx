<?php

class XML
{
  public static function node($nodeName, $value, $attributes = null)
  {
    $result = '';
    $xml = self::serialize($value, $nodeName);

    if ($xml)
    {
      $result = '<' . $nodeName;
      foreach ($attributes as $name => $attribute)
        $result .= ' ' . self::attribute($name, $attribute);
      $result .=  '>' . $xml . '</' . $nodeName . '>';
    }

    return $result;
  }

  public static function attribute($name, $value)
  {
    return $name . '="' . self::serialize($value . '') . '"';
  }

  public static function serialize($value, $name = null)
  {
    if (is_array($value))
      return self::serializeArray($value, $name);
    else if (is_object($value))
      return self::serializeObject($value);
    else if (is_string($value))
    {
      if (preg_match('/[&<>]+/', $value) != 0)
	return '<![CDATA[' . $value . ']]>';
      else
	return $value;
    }
    else if (is_numeric($value))
      return '' . $value;
    else if (is_bool($value))
      return $value ? 'true' : 'false';

    return false;
  }

  private static function serializeArray($array, $name = null)
  {
    $result = '';

    foreach ($array as $key => $value)
    {
      if (is_object($value))
      {
        $result .= self::serializeObject($value);
      }
      else
      {
        $nodeName = is_numeric($key)
                    ? ($name ? $name : '_' . $key)
                    : $key;

        $result .= '<' . $nodeName . '>'
                   . self::serialize($value)
                   . '</' . $nodeName . '>';
      }
    }

    return $result;
  }

  public static function serializeObject($object,
                                         $exclude       = null,
                                         $noRoot	= false)
  {
    if (method_exists($object, 'toXML'))
      return $object->toXML($exclude, $noRoot);

    if (method_exists($object, 'getProperties'))
    {
      $properties = $object->getProperties();
    }
    else
    {
      $rClass     = new ReflectionClass($object);
      $properties = $rClass->getProperties(ReflectionProperty::IS_PUBLIC);
    }

    $rootName    = $noRoot ? '' : strtolower(get_class($object));
    $result	 = $noRoot ? '' : '<' . $rootName . '>';

    foreach ($properties as $propertyName)
    {
      if (!$exclude || false === array_search($propertyName, $exclude, true))
      {
        $str = self::serialize($object->$propertyName);

        if ($str)
        {
          $result .= '<' . $propertyName . '>'
                     . $str
                     . '</' . $propertyName . '>';
        }
      }
    }

    if (!$noRoot)
      $result .= '</' . $rootName . '>';

    return $result;
  }
}

?>