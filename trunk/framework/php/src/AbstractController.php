<?php

abstract class AbstractController extends XMLResponseElement
{
  private $proxy        = null;

  public function AbstractController($proxy = null)
  {
    parent::XMLResponseElement(null);

    $this->proxy = $proxy;
  }

  public function __call($p, $a)
  {
    if ($this->proxy && method_exists($this->proxy, $p))
      return call_user_func_array(array($this->proxy, $p), $a);

    throw new UnknownMethodException(get_class($this) . '::' . $p, $a);
  }

}

?>