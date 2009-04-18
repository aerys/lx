INTRODUCTION
------------

LX is a MVC framework. LX was not designed to be a website framework but a web
platform framework. The difference lies in the fact that LX applications are
actual webiste only when they are open using a web browser.

Despite the fact that its default implementation uses PHP and MySQL, it can be
extended to use any language/DBMS.

LX relies on a W3C standard called XSL to transform XML declaration files into
configuration and implementation files. XSL is also used to managed templates
and layouts so that the view is entirely separated from the controlers and can
be fully cached by the web browser.


SCRIPTS
-------

Scripts are located in the /core/scripts directory.
Each script can be executed using the following command line:

php [script_file.php] [arguments...]

The available scripts are:

- lx-reload.php
  Clear the /tmp folder and re-transform every model located
  in the /application/models directory using current backends

- lx-orm.php [model.xml] [backend.xsl]
  Print the result of the transformation of model.xml using
  backend.xsl



MAKEFILE
--------

Each LX application comes with a Makefile (and a configure script).
This Makefile implements the following rules:

all: reload

models:
	generate all models

lx-project.php:
	generate the lx-project.php file

reload: clean lx-project.php models



VIRTUALHOST CONFIGURATION
-------------------------

<VirtualHost *:80>
        ServerName my.servername.com
        DocumentRoot /var/www/servername.com/public
</VirtualHost>
