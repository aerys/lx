<?php

abstract class AbstractController extends XMLResponseElement
{
  public function AbstractController($my_controller = NULL)
  {
    parent::XMLResponseElement($my_controller ? $my_controller->getFragment() : NULL);
  }

  abstract public function defaultAction();

  public function __call($p, $a)
  {
    throw new UnknownMethodException(get_class($this) . '::' . $p, $a);
  }

}

?>