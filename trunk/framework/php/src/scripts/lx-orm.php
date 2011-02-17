<?php

require_once ('../misc/lx-bootstrap.php');
require_once ('../misc/lx-configure.php');

$model = $argv[1];
$backend = LX_XSL . '/orm/' . $argv[2];

AbstractModel::scaffold($model,
                        $backend,
                        'php://output');

?>