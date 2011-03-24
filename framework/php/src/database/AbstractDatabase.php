<?php

abstract class AbstractDatabase
{
  abstract public function connect();
  abstract public function disconnect();

  abstract public function createQuery($query);
  abstract public function performQuery($query, $type = null);

  abstract public function getInsertId();

  abstract public function escapeString($str);
};

?>