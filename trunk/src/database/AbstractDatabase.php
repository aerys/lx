<?php

abstract class AbstractDatabase
{
  abstract public function connect();
  abstract public function disconnect();

  abstract public function createQuery($my_query);
  abstract public function performQuery($my_query);

  abstract public function getInsertId();

  abstract public function escapeString($my_str);
};

?>