LX web platform framework
=========================


LX is a MVC framework.  LX was not designed to be a website framework but a
web platform framework.  The difference lies in the fact that LX applications
are actual website only when they are open using a web browser.

Despite the fact that its default implementation uses PHP and MySQL, it can be
extended to use any language/DBMS.

LX relies on a W3C standard called XSL to transform XML declaration files into
configuration and implementation files.  XSL is also used to managed templates
and layouts so that the view is entirely separated from the controllers and
can be fully cached by the web browser.  In fact, it is perfectly suitable for
REST applications.


Installation
------------

1. Clone the repository
2. Make sure the PHP interpreter is in your `$PATH`
3. Add an environment variable `$LX_HOME` set to `/path/to/lx/framework`
4. Add `$LX_HOME/bin` to your `$PATH`

It should work on Linux, Windows and Mac.


Usage
-----

You should use `lx-cli` to manage your project:

* `lx-cli create <project>` -- deploy *project* skeleton in current directory
* `lx-cli create <project> in <directory>` -- deploy *project* skeleton in *directory*
* `lx-cli update` -- update both configuration files and models
* `lx-cli update config` -- update configuration files
* `lx-cli update models` -- update models
* `lx-cli update lib` -- force a copy of the lib again (useful after git update) (Windows only)
* `lx-cli help` -- display commands


Contribute
----------

`lx` is LGPL-licensed.  Make sure you tell us everything that's wrong!

* [Source code](https://github.com/aerys/lx)
* [Issue tracker](https://github.com/aerys/lx/issues)
