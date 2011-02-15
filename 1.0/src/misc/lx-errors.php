<?php

function lx_error_handler($my_errno,
			  $my_errstr,
			  $my_errfile,
			  $my_errline,
			  $my_context)
{
  // FIXME
  throw new ErrorException($my_errstr, 0, $my_errno, $my_errfile, $my_errline);

  /* Don't execute PHP internal error handler */
  return (true);
}

set_error_handler('lx_error_handler');

?>