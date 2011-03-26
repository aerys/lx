@echo off

if "%OS%"=="Windows_NT" @setlocal

rem echo ----------------------------------------------------------------------------------------
rem echo WARNING: You must have PHP folder added to your PATH variable.
rem echo WARNING: You must have LX_HOME defined to '/lx/framework' in your environment variables.
rem echo ----------------------------------------------------------------------------------------

cls

rem php.exe -f LX_HOME/script/lx-cli.php [OS] [CURRENT_DIR] [ARGS]



if exist mklink ( goto modern ) else (goto oldschool )

:oldschool
call php.exe -f %LX_HOME%/script/lx-cli.php old %cd% %*
goto exit

:modern
call php.exe -f %LX_HOME%/script/lx-cli.php win %cd% %*
goto exit


:exit
if "%OS%"=="Windows_NT" @endlocal
