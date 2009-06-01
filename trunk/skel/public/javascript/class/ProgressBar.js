function ProgressBar(mySource, myWidth, myHeight)
{
	EventDispatcher.call(this);
	
	this._source = mySource;	
	this._source.addEventListener(ProgressEvent.PROGRESS,
								  this._progressHandler.bind(this));
	this._source.addEventListener(Event.COMPLETE,
								  this._completeHandler.bind(this));
	
	this._element = document.createElement("div");
	this._element.setAttribute("class", "progressbar");
	
	this._label = document.createElement("div");
	this._label.setAttribute("class", "label");
	this._label.innerHTML = "Loading...";
	
	this._bar = document.createElement("div");
	this._bar.setAttribute("class", "bar");
	this._bar.style.height = "100%";

	this._container = document.createElement("div");
	this._container.setAttribute("class", "container");
	this._container.appendChild(this._bar);

	this.setWidth(myWidth != null ? myWidth : ProgressBar.DEFAULT_WIDTH);
	this.setHeight(myHeight != null ? myHeight : ProgressBar.DEFAULT_HEIGHT);

	this._element.appendChild(this._label);
	this._element.appendChild(this._container);
}
ProgressBar.inherits(EventDispatcher);

ProgressBar.DEFAULT_WIDTH			= "100px";
ProgressBar.DEFAULT_HEIGHT			= "20px";

ProgressBar.prototype._source	= null;
ProgressBar.prototype._element	= null;
ProgressBar.prototype._bar		= null;
ProgressBar.prototype._label	= null;

ProgressBar.prototype.getHTMLElement	= function()	{return (this._element);}
ProgressBar.prototype.getLabel			= function()	{return (l);}

ProgressBar.prototype.setWidth			= function(w)	{this._container.style.width = w;};
ProgressBar.prototype.setHeight			= function(h)	{this._container.style.height = h;};
ProgressBar.prototype.setLabel			= function(l)	{this._label.innerHTML = l;}

ProgressBar.prototype._progressHandler = function(e)
{
	this._bar.style.width = (e.getProgress() * 100) + "%";
	this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, this, e.getProgress()));
}

ProgressBar.prototype._completeHandler = function(e)
{
	this._bar.style.width = "100%";
	this.dispatchEvent(new Event(Event.COMPLETE, this));
}
