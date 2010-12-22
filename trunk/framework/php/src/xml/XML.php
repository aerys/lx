<?php

class XML
{
  public static function serialize($value, $name = null)
  {
    if (is_array($value))
      return self::serializeArray($value, $name);
    else if (is_string($value))
      return '<![CDATA[' . $value . ']]>';
    else if (is_numeric($value))
      return '' . $k;
    else if (is_bool($value))
      return $value ? 'true' : 'false';
  }

  private static function serializeArray($array, $name = null)
  {
    $result = '';

    foreach ($array as $key => $value)
    {
      $nodeName = is_numeric($key) ? ($name ? $name : '_' . $key)
                                   : $key;

      $result .= '<' . $nodeName . '>'
                 . self::serialize($value)
                 . '</' . $nodeName . '>';
    }

    return $result;
  }

  private static function serializeObject($object, $name = '')
  {
    if ($object instanceof XMLSerializable)
      return $object->__toString();

    $rClass = new ReflectionClass($object);
    $rMethods = $rClass->getMethods(ReflectionMethod::IS_PUBLIC);

    if (array_search('toXML', $rMethods))
      return $object->toXML($name);

    $rProperties = $rClass->getProperties(ReflectionProperty::IS_PUBLIC);
    $result = '';

    foreach ($rProperties as $propertyName)
      $result .= self::serialize($object->$propertyName, $propertyName);

    return $result;
  }
}

?>