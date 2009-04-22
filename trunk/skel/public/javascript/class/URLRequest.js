function URLRequest(my_url)
{
    EventDispatcher.call(this);

    this._url = my_url;

    this._initialize();
}
URLRequest.inherits(EventDispatcher);

/* STATIC */
URLRequest.READYSTATE_UNINITIALIZED	= 0;
URLRequest.READYSTATE_LOADING		= 1;
URLRequest.READYSTATE_LOADED		= 2;
URLRequest.READYSTATE_INTERACTIVE	= 3;
URLRequest.READYSTATE_COMPLETE		= 4;

URLRequest.METHOD_GET			= "GET";
URLRequest.METHOD_POST			= "POST";

/* VARS */
URLRequest.prototype._url		= "";
URLRequest.prototype._xmlHttpRequest	= null;
URLRequest.prototype._method		= URLRequest.METHOD_GET;
URLRequest.prototype._data		= null;

/* PROPERTIES */
URLRequest.prototype.getUrl		= function()		{return (this._url);}
URLRequest.prototype.getMethod		= function()		{return (this._method);}
URLRequest.prototype.getResponseText	= function()		{return (this._xmlHttpRequest.responseText);}
URLRequest.prototype.getResponseXML	= function()		{return (this._xmlHttpRequest.responseXML);}

URLRequest.prototype.setUrl		= function(my_url)	{this._url = my_url;}
URLRequest.prototype.setMethod		= function(my_met)	{this._method = my_met;}
URLRequest.prototype.setData		= function(my_data)	{this._data = my_data;}

/* METHODS */
URLRequest.prototype._initialize = function()
{
    var req = null;

    if (window.XMLHttpRequest)
    {
	req = new XMLHttpRequest();
    }
    else if (window.ActiveXObject)
    {
	try
	{
	    req = new ActiveXObject("Msxml2.XMLHTTP");
	}
	catch (e)
	{
	    try
	    {
		req = new ActiveXObject("Microsoft.XMLHTTP");
	    }
	    catch (e)
	    {
		// FIXME: Error!
	    }
	}
    }

    this._xmlHttpRequest = req;
}

URLRequest.prototype._onReadyStateChange = function()
{
    var ready    = this._xmlHttpRequest.readyState;

    if (ready == URLRequest.READYSTATE_COMPLETE)
    {
	var xml = this.getResponseXML();
	var exceptions = null;

	if (xml.getElementsByTagNameNS)
	{
	   exceptions = xml.getElementsByTagNameNS("http://lx.promethe.net",
	                                           "error");
	}
	else
	{
	    exceptions = xml.getElementsByTagName("lx:error");
	}

	if (exceptions.length)
	{
	    //alert(this.getResponseText());
	    this.dispatchEvent(new Event(Event.ERROR, this));
	}
	else
	{
	    this.dispatchEvent(new ProgressEvent(ProgressEvent.COMPLETE,
						 this));
	}
    }
    else
    {
        this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS,
					     this,
					     ready));
    }
}

URLRequest.prototype.send = function(my_async)
{
    var params	= "";
    var url	= this._url;

    my_async = my_async ? my_async : true;

    for (var param in this._data)
	if (this._data[param] != "")
	    params += (params ? "&" : "") + param + "=" + this._data[param];

    if (this._method == URLRequest.METHOD_GET && params != "")
	url += "?" + params;

    /* BEGIN FIREFOX ONLY */
    // Enable security privileges for filesystem ('file://...') requests
    if (window.location.href.substring(0, 5) == "file:"
	&& (typeof netscape != "undefined" && typeof netscape.security != "undefined"))
	netscape.security.PrivilegeManager.enablePrivilege("UniversalBrowserRead");
    /* END FIREFOX ONLY */

    if (this._xmlHttpRequest && this._xmlHttpRequest.readyState)
    {
	// stop the request
	this._xmlHttpRequest.onreadystatechange = null;
	this._xmlHttpRequest.abort();
	this._xmlHttpRequest = null;

	// get a new XmlHttpRequest
	this._initialize();
    }

    try
    {
	this._xmlHttpRequest.onreadystatechange = this._onReadyStateChange.bind(this);
	this._xmlHttpRequest.open(this._method, url, my_async);

	if (this._method == URLRequest.METHOD_POST)
	    this._xmlHttpRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

	this._xmlHttpRequest.send(params);

	if (!my_async && (this._xmlHttpRequest.readyState == URLRequest.READYSTATE_COMPLETE))
	{
	    this.dispatchEvent(new ProgressEvent(ProgressEvent.COMPLETE, this));
	}
	else if (!my_async)
	{
	    this.dispatchEvent(new Event(Event.ERROR, this));

	    return (false);
	}
    }
    catch (e)
    {
	this.dispatchEvent(new Event(Event.ERROR, this, e.message));

	return (false);
    }

    return (true);
}
