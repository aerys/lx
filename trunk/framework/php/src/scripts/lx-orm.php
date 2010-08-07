<?php

require_once ('../misc/lx-config.php');

$model = $argv[1];
$backend = LX_XSL . '/orm/' . $argv[2];

AbstractModel::scaffold($model,
			$backend,
			'php://output');

?>