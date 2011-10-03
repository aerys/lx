<?php

define('LX_HOME',       getenv('LX_HOME'));
define('T',             "\t");
define('SYS',           $argv[1]);
define('CURRENT',       $argv[2]);
define('DEBUG',         false);

function error($message)
{
	die('Error: ' . $message . PHP_EOL);
}

function execute_task($message,
					  $cmd,
					  $stdout   = false,
					  $stderr   = false)
{
	$r = 0;

	echo $message;

	if (SYS === 'posix')
	{
		if (!$stdout)
			$cmd .= ' > /dev/null';
		if (!$stderr)
			$cmd .= ' 2> /dev/null';
	}

	if (DEBUG)
		echo PHP_EOL . $cmd . PHP_EOL;

	exec($cmd, $cmd, $r);

	if ($cmd && ($stdout || $stderr || $r))
	{
		echo PHP_EOL;
		foreach ($cmd as $line)
			echo $line . PHP_EOL;
		echo $message;
	}

	for ($i = strlen($message); $i < 76; $i++)
		echo ' ';
	echo ($r === 0 ? '[OK]' : '[KO]') . PHP_EOL;

	return $r === 0;
}

function copy_dir($src, $dst, $mkdir = false)
{
	$dir = opendir($src);
	if ($mkdir)
		@mkdir($dst);

	while (false !== ($file = readdir($dir)))
	{
		if (($file != '.') && ($file != '..'))
		{
			if (is_dir($src . '/' . $file))
				copy_dir($src  .  '/'  . $file, $dst . '/' . $file, true);
			else
				copy($src . '/' . $file, $dst . '/' . $file);
		}
	}

	closedir($dir);
}

function rm_rf($dir)
{
	if (is_dir($dir))
	{
		$objects = scandir($dir);

		foreach ($objects as $object)
		{
			if ($object != '.' && $object != '..')
			{
				if (filetype($dir . '/' . $object) == 'dir')
					rm_rf($dir . '/' . $object);
				else
					unlink($dir . '/' . $object);
			}
		}

		reset($objects);
		rmdir($dir);
	}
}

function copy_ext($src, $ext, $dst)
{
	if (!is_dir($src))
		die('ERROR: ' . $src);

	$dir = opendir($src);

	while(false !== ($file = readdir($dir)))
	{
		if (!is_dir($file) && ($file != '.') && ($file != '..') && (substr($file, -strlen($ext)) == $ext))
		{
			copy($src . '/' . $file, $dst . '/' . $file);
		}
	}

	closedir($dir);
}

function create($path, $name, $archetype = null)
{
	$out = '';
	if (!is_dir($path))
		die('\'' . $path . '\' is not a valid directory.');

	@mkdir($path . '/' . $name);
	@mkdir($path . '/' . $name . '/bin');
	@mkdir($path . '/' . $name . '/bin/models');

	copy_dir(LX_HOME . '/archetype/default', $path . '/' . $name);
	if ($archetype && $archetype != 'default' && is_dir(LX_HOME . '/archetype/' . $archetype))
		copy_dir(LX_HOME . '/archetype/' . $archetype, $path . '/' . $name);

	@mkdir($path . '/' . $name . '/src/models');
	@mkdir($path . '/' . $name . '/lib');

	if (SYS === 'old')
	{
		@mkdir($path . '/' . $name . '/lib/lx');

		//old school windows (<= XP) does not support any ln -s so we have to copy all the lib right into the project
		copy_dir(LX_HOME, $path . '/' . $name . '/lib/lx');
		rm_rf($path . '/' . $name . '/lib/lx/project');

		copy_ext(LX_HOME . 'xsl/src', 'xsl', $path . '/' . $name . '/src/views');
	}
	else if (SYS === 'win') //new windows (Vista/7) support mklink /D (ln -s alternative)
	{
		$escaped = str_replace('\\', '/', $path);

		exec('mklink /D "' . $escaped . '/' . $name . '/lib/lx" "' . LX_HOME . '/framework"');

		$src = LX_HOME . '/framework/xsl/src';
		$dir = opendir($src);

		while(false !== ($file = readdir($dir)))
		{
			if (!is_dir($file) && ($file != '.') && ($file != '..') && (substr($file, -3) == "xsl"))
			{
				exec('mklink /D "' . $escaped . '/' . $name . '/src/views/' . $file . '" "' . $src . '/' . $file . '"');
			}
		}

		closedir($dir);
	}
	else //any other unix based shell
	{
		exec('ln -s ' . LX_HOME . '/framework ' . $path . '/' . $name . '/lib/lx');
		exec('ln -s ' . LX_HOME . '/framework/xsl/src/*.xsl ' . $path . '/' . $name . '/src/views/');
	}

	exec('cd ' . $path . '/' . $name . ' && ' . LX_HOME . '/bin/lx-cli'
		 . (SYS !== 'posix' ? '.bat' : '') . ' update');

	return $out;
}

function update($config = null)
{
	if (!file_exists(CURRENT . '/lx-project.xml'))
		error('the current directory is not an LX project');

	@mkdir(CURRENT . '/bin');
	@mkdir(CURRENT . '/bin/models');

	lib();
	config(CURRENT, $config);
	models();
}

function lib()
{
	$out = 'This undocumented feature is windows only';
	if (SYS === 'old')
		copy_dir(LX_HOME . '/framework/php', CURRENT . '/lib/lx');

	return $out;
}

function config($root = CURRENT, $config = null)
{
	if (substr(exec('php --rc XSLTProcessor'), 0, 1) == 'E')
		error('XSLT PHP extension is not available');

	execute_task('Building configuration (php)... ',
                 'php '
                 . LX_HOME . '/script/lx-project.php '
                 . $root . '/lx-project.xml > ' . $root . '/bin/lx-project.php'
                 . ($config != null ? ' ' . $config : ''),
                 true);

 	execute_task('Building configuration (xsl)... ',
                 'php '
                 . LX_HOME . '/script/lx-project.php '
                 . $root . '/lx-project.xml > ' . $root . '/bin/lx-project.xsl xsl',
                 true);
}

function models()
{
	$models       = array();
	$dir          = opendir(CURRENT . '/src/models');

        if (!$dir)
                return false;

	while(false !== ($file = readdir($dir)))
		if (($file != '.') && ($file != '..') && (substr($file, -3, 3) == 'xml'))
			array_push($models, substr($file, 0, -4));

	closedir($dir);

	foreach($models as $model)
	{
		execute_task('Building model \'' . $model . '\'... ',
                 'php -f '
                 . LX_HOME . '/script/lx-orm.php'
                 . ' src/models/' . $model . '.xml lx-php-orm.xsl'
                 . ' > bin/models/' . $model . '.php'
                 . ' ' . CURRENT,
                 true);
	}
}

function export($project = "")
{
	if (!$project)
		$project = CURRENT;

	if ($project && !(is_dir($project) && file_exists($project . '/lx-project.xml')))
		error('\'' . $project . '\' is not a valid LX project');

	config($project);
	require_once($project . '/bin/lx-project.php');

	// export databases
	if (count($_LX['databases']))
	{
		foreach ($_LX['databases'] as $db)
		{
			switch ($db['type'])
			{
				case 'mysql':
				default:
					export_mysql($db, $project);
					break;
			}
		}
	}
	else
	{
		echo 'No database to export' . PHP_EOL;
	}

	// export the project
	$basename = basename($project);
	$archive = $basename . '-' . date('Ymd') . '.tgz';

	//FIX: tar is not windows native ; use of zip and zip php extension instead ?
	execute_task('Exporting project to \'' . realpath($project . '/..') . '/' . $archive . '\'... ',
               'cd ' . realpath($project . '/..')
	. ' && tar czf ' . $archive . ' ' . $basename
	. ' --exclude-vcs');
}

function export_mysql($db, $root = CURRENT)
{
	//FIX: mysqldump needs to be added to $PATH on windows
	execute_task('Exporting database \'' . $db['name'] . '.sql\'... ',
               'mysqldump'
               . ' -u ' . $db['user']
               . ' -h ' . $db['host']
               . (isset($db['password']) && $db['password'] ? ' -p' . $db['password'] : '')
               . ' --skip-extended-insert --skip-comments'
               . ' --databases ' . $db['name']
               . ' > ' . $root . '/' . $db['name'] . '.sql',
               true);
}

function import($archive = null)
{
	$dl = false;

	if ($archive)
	{
		if (!file_exists($archive))
		{
			if (preg_match('/^http:\/\/.*/', $archive) !== 0)
			{
				$tmp = tempnam(null, 'lx');
				$filename = substr($archive,
				strrpos($archive, '/') + 1);

				echo 'Downloading archive \'' . $filename . '\' to '
				. '\'' . $tmp . '\'... ';

				$data = file_get_contents($archive);
				if ($data === false)
				{
					echo 'KO' . PHP_EOL;
					error('unable to download \'' . $archive . '\'');
				}
				else
				{
					echo 'OK' . PHP_EOL;
				}

				$file = fopen($tmp, 'w');
				fwrite($file, $data);
				fclose($file);

				$archive = $tmp;
				$dir = substr($filename, 0, strrpos($filename, '.'));
			}
			else
			{
				error('\'' . $archive . '\' does not exists.');
			}
		}
		else
		{
			$dir = substr($archive, 0, strrpos($archive, '.'));
		}

		//FIX: tar is not windows native ; use of zip and zip php extension instead ?
		$tar = execute_task('Extracting project from archive \'' . $archive . '\'... ',
                        'tar xvf ' . $archive);

		if ($dl)
		unlink($archive);

		if ($tar)
                  echo exec('cd ' . $dir . ' && ' . LX_HOME . '/bin/lx-cli.sh import') . PHP_EOL;
		else
                  error('unable to extract');
        }
        else
        {
          require_once(CURRENT . '/bin/lx-project.php');

          if (count($_LX['databases']) == 0)
            error('no database to import');

          foreach ($_LX['databases'] as $db)
          {
            switch ($db['type'])
            {
              case 'mysql':
              default:
                import_mysql($db);
              break;
            }
          }
        }
}

function import_mysql($db)
{
	$filename = CURRENT . '/' . $db['name'] . '.sql';
	if (!file_exists($filename))
		error('unable to import database: \'' . $filename . '\' is missing.');

	//FIX: cat not supported in windows
	execute_task('Importing database \'' . $db['name'] . '.sql\'... ',
               'cat ' . $filename
				. ' | mysql'
				. ' -h ' . $db['host']
				. ' -u ' . $db['user']
				. (isset($db['password']) && $db['password'] ? ' -p' . $db['password'] : ''));
}

function doctor($path = null)
{
	$path = dirname($path ? $path : 'project.xml');

	execute_task('Checking for $LX_HOME environment variable',
               'set -e; : ${LX_HOME:?"Need to set LX_HOME non-empty"}');
	execute_task('Checking for invalid symlinks ('.$path.'/src/views/)',
               'set -e; for XSL in '.$path.'/src/views/*.xsl; do test -e $XSL; done');
	execute_task('Checking for GNU tools (tar, ls)',
               'set -e; `which tar` --version | grep -q GNU && `which ls` --version | grep -q GNU');
	execute_task('Checking for generated files',
               'set -e; test -e '.$path.'/bin/lx-project.php');
}

function help()
{
	return 'Usage: lx-cli [%action=update]' . PHP_EOL
	. 'Actions:' . PHP_EOL
	. '  create %project [%archetype]' . T . 'Deploy a new project named %project in your current directory' . PHP_EOL
	. '  update' . T . T . T. 'Update all project files (configuration and models)' . PHP_EOL
	. '  update config' . T . T . T . 'Update configuration files only' . PHP_EOL
	. '  update models' . T . T . T . 'Update models only' . PHP_EOL
	. '  import [%archive]' . T . T . 'Import a project [from the %archive archive]' . PHP_EOL
	. '  export [%project]' . T . T . 'Export the %project project or the current directory project' . PHP_EOL
	. '  doctor [%project]' . T . T . 'Check the project for potential problems' . PHP_EOL
	. '  help' . T . T . T . T . 'Display this message' . PHP_EOL;
}

if (DEBUG)
	print_r($argv);

if (count($argv) < 4)
	die(update());

switch($argv[3])
{
	case 'create':
		if (isset($argv[4]))
		{
			$name = $argv[4];
			$path = $argv[2];

			create($path, $name, isset($argv[5]) ? $argv[5] : null);
		}
		else
			die('error');
		break;

	case 'export':
		if (isset($argv[4]))
			die(export($argv[4]));
		else
			die(export());
		break;

	case 'import':
		die(import(isset($argv[4]) ? $argv[4] : null));
		break;

	case 'doctor':
		die(doctor(isset($argv[4]) ? $argv[4] : null));

	case 'help':
		die(help());
		break;

	case 'update':
		die(update(isset($argv[4]) ? $argv[4] : null));

	default:
		die(update());
		break;
}

?>