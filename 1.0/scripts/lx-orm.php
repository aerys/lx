<?php

require_once ('../src/misc/lx-config.php');

$model = $argv[1];
$backend = LX_XSL . '/' . $argv[2];

AbstractModel::scaffold($model,
			$backend,
			'php://output');

?>