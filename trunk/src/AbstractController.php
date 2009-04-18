<?php

abstract class AbstractController extends XMLResponseElement
{
  public function AbstractController()
  {
    parent::XMLResponseElement();
  }

  abstract public function defaultAction();

  public function __call($p, $a)
  {
    throw new UnknownMethodException(get_class($this) . '::' . $p,
				     $a);
  }

}

?>