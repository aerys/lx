<?php

class DefaultController extends AbstractController
{
  public function defaultAction()
  {
    LX::setTemplate('default');
  }
}