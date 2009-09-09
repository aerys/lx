<?php

require_once ('../tmp/lx-project.php');

LX::dispatchHTTPRequest($_SERVER['REDIRECT_URL'], $_GET, $_POST);

?>