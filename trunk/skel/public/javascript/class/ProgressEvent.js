function ProgressEvent(my_id, my_target, my_progress)
{
    Event.call(this, my_id, my_target);

    this._progress = my_progress;
}
ProgressEvent.inherits(Event);

ProgressEvent.PROGRESS	= 'progress';
ProgressEvent.COMPLETE	= 'complete';

ProgressEvent.prototype.getProgress	= function()	{return (this._progress);}