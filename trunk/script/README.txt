TODO:
Linux/OSX .sh launcher



LXCLI
=====

Commands :
----------

lxcli create %project :
	deploy %project skeleton in current directory

lxcli create %project in %dir :
	deploy %project skeleton in %dir directory

update :
	update both configuration files and models
	
update config :
	update configuration files
	
update models :
	update models
	
help :
	display commands

*** WINDOWS ONLY ***
update lib :
	force a copy of the lib again (usefull after git update)
	
	
	



Windows prerequisites :
-----------------------

1/ Add BOTH "/path/to/bin/php" folder and "/path/to/lib/lx/framework" folder to PATH Environnment variable.
	
2/ Add LX_HOME to "/path/to/lib/lx/framework" to PATH Environnment variable.


Linux/OSX prerequisites :
-------------------------

1/ Add env. variable LX_HOME to "/path/to/lib/lx/framework" :
	- linux : in ~/.bashrc
	- OSX : in ~/.bash_profile
	
2/ type : ln -s $LX_HOME/lxcli.sh /usr/local/bin to add lxcli.sh as a global command