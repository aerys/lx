@echo off

if "%OS%"=="Windows_NT" @setlocal

rem echo ----------------------------------------------------------------------------------------
rem echo WARNING: You must have PHP folder added to your PATH variable
rem echo WARNING: You must have LX_HOME defined to '/lx/framework' in your environnment variables
rem echo ----------------------------------------------------------------------------------------

cls

rem php.exe -f LX_HOME/lxcli.php [OS] [CURRENT_DIR] [ARGS]
call php.exe -f %LX_HOME%/lxcli.php win %cd% %* 

if "%OS%"=="Windows_NT" @endlocal