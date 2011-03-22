<?php

class ResultSet implements Iterator, IXMLSerializable
{
  private $data         = null;
  private $current      = 0;

  public function getArray()
  {
    return $data;
  }

  public function ResultSet(array $data)
  {
    $this->data = $data;
  }

  public function rewind()
  {
    $this->current = 0;
  }

  public function next()
  {
    $this->current++;
  }

  public function key()
  {
    return 'increment '.$this->current + 1;
  }

  public function current()
  {
    return $this->current;
  }

  public function valid()
  {
    return $this->current <= count($this->data);
  }

  public function size()
  {
    return count($this->data);
  }

  public function get($index)
  {
    return $this->data[$index];
  }

  public function toXML($exclude        = null,
                        $noRoot         = false)
  {
    return XML::serializeArray($this->data);
  }
}

?>