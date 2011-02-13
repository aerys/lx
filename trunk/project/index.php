<?php

require_once ('bin/lx-project.php');

LX::dispatchHTTPRequest($_SERVER['REQUEST_URI'], $_GET, $_POST);

?>