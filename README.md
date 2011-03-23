LX web framework
================

LX is a web framework which is based on a REST approach.  It serves XML and
tries to render the document on the client side thanks to XSL transformations.


Installation
------------

1. Clone the repository
2. Make sure PHP is in your $PATH
3. Add an environment variable LX_HOME set to `/path/to/lx/framework`
4. Add $LX_HOME/bin to your $PATH

It should work on Linux, Windows and Mac.


Usage
-----

You should use `lx-cli` to manage your project:

* `lx-cli create <project>` -- deploy <project> skeleton in current directory
* `lx-cli create <project> in <directory> -- deploy <project> skeleton in <directory>
* `lx-cli update` -- update both configuration files and models
* `lx-cli update config` -- update configuration files
* `lx-cli update models` -- update models
* `lx-cli update lib` -- force a copy of the lib again (useful after git update) **WINDOWS ONLY**
* `lx-cli help` -- display commands


Contribute
----------

`lx` is LGPL-licensed.  We love bug reports and pull requests!

* [Source code](https://github.com/aerys/lx)
* [Issue tracker](https://github.com/aerys/lx/issues)
* [Documentation](http://aerys.github.com/lx/)
