function EventDispatcher()
{
    this._events = new Array();
}

/* VARS */
EventDispatcher.prototype._events	= null;

/* METHODS */
EventDispatcher.prototype.addEventListener = function(my_eventId,
						      my_callBack)
{
    if (!this._events[my_eventId])
        this._events[my_eventId] = new Array();
    this._events[my_eventId].push(my_callBack);
}

EventDispatcher.prototype.dispatchEvent = function(my_event)
{
    var id = my_event.getId();

    if (!this._events[id])
        return ;
    for (var i in this._events[id])
    {
        if (this._events[id][i])
            this._events[id][i].call(this, my_event);
    }
}

EventDispatcher.prototype.toString = function()
{
    return ("[object EventDispatcher]");
}
