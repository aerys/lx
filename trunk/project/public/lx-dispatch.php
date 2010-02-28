<?php

require_once ('../bin/lx-project.php');

LX::dispatchHTTPRequest($_SERVER['REDIRECT_URL'], $_GET, $_POST);

?>