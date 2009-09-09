<?php

class HomeController extends AbstractController
{
  public function home()
  {
    LX::setTemplate('default');
  }
}