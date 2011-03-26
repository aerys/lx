<?php

define('LX_HOME', getenv('LX_HOME'));
require_once (LX_HOME . '/framework/php/src/misc/lx-bootstrap.php');
require_once (LX_HOME . '/framework/php/src/misc/lx-configure.php');

$model = $argv[1];
$backend = LX_XSL . '/orm/' . $argv[2];
$xslinclude = $argv[3] . '/bin/lx-project.xsl';

AbstractModel::scaffold($model,
                        $backend,
                        'php://output',
                        $xslinclude);

?>