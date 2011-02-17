<?php

require_once ('../misc/lx-bootstrap.php');
require_once ('../misc/lx-constants.php');

$model = $argv[1];
$backend = LX_XSL . '/orm/' . $argv[2];

AbstractModel::scaffold($model,
                        $backend,
                        'php://output');

?>