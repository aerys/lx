<?php

class XML
{
  public static function cdata($text)
  {
    return '<![CDATA[' . $text . ']]>';
  }
}

?>