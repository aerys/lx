function Event(my_id, my_target)
{
    this._id = my_id ? my_id : "";
    this._target = my_target;
}

/* STATIC */
Event.CHANGE    = "change";
Event.RESIZE    = "resize";
Event.SHOW      = "show";
Event.HIDE      = "hide";
Event.ERROR	= "error";
Event.COMPLETE	= "complete";
/* ! STATIC */

/* VARS */
Event.prototype._id	= "";
Event.prototype._target	= null;
/* ! VARS */

Event.prototype.getId		= function() {return (this._id)};
Event.prototype.getTarget	= function() {return (this._target)};

/* METHODS */
Event.prototype.toString = function()
{
	return ("[object Event(id: " + this._id + ")]");
}
/* ! METHODS */
