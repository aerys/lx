function FlashApplication(my_src, my_id)
{
    EventDispatcher.call(this);

    this.src = my_src;
    if (my_id)
	this.id = my_id;

    // generating random bridgeName
    this.bridgeName = this.id + Math.round(Math.random() * 1000000);

    window[this.bridgeName] = this;
}
FlashApplication.inherits(EventDispatcher);

/* STATIC */
FlashApplication.MERGEMODE_NONE				= 1;
FlashApplication.MERGEMODE_FULL				= 2;

FlashApplication.DEFAULT_ID				= 'flashApplication';
FlashApplication.DEFAULT_WIDTH				= '100%';
FlashApplication.DEFAULT_HEIGHT				= '100%';
FlashApplication.DEFAULT_ALTERNATE_CONTENT		= 'This content requires the Adobe Flash Player. <a href=http://www.adobe.com/go/getflash/>Get Flash</a>';
FlashApplication.DEFAULT_WMODE				= '';
FlashApplication.DEFAULT_QUALITY			= 'high';
FlashApplication.DEFAULT_ALLOW_SCRIPT_ACCESS		= 'sameDomain';
FlashApplication.DEFAULT_ALLOW_FULLSCREEN		= 'true';
FlashApplication.DEFAULT_ALIGN				= 'middle';
FlashApplication.DEFAULT_BGCOLOR			= '#ffffff';
FlashApplication.DEFAULT_USEFABRIDGE			= false;
FlashApplication.DEFAULT_MERGEMODE			= FlashApplication.MERGEMODE_FULL;

FlashApplication.DEFAULT_REQUIRED_MAJOR_VERSION		= 10;
FlashApplication.DEFAULT_REQUIRED_MINOR_VERSION		= 0;
FlashApplication.DEFAULT_REQUIRED_REVISION		= 22;
/* ! STATIC */

/* VARS */
FlashApplication.prototype.id				= FlashApplication.DEFAULT_ID;
FlashApplication.prototype.bridgeName			= '';
FlashApplication.prototype.width			= FlashApplication.DEFAULT_WIDTH;
FlashApplication.prototype.height			= FlashApplication.DEFAULT_HEIGHT;
FlashApplication.prototype.src				= '';
FlashApplication.prototype.quality			= FlashApplication.DEFAULT_QUALITY;
FlashApplication.prototype.wmode			= FlashApplication.DEFAULT_WMODE;
FlashApplication.prototype.allowScriptAccess		= FlashApplication.DEFAULT_ALLOW_SCRIPT_ACCESS;
FlashApplication.prototype.allowFullscreen		= FlashApplication.DEFAULT_ALLOW_FULLSCREEN;
FlashApplication.prototype.alternateContent		= FlashApplication.DEFAULT_ALTERNATE_CONTENT;
FlashApplication.prototype.align			= FlashApplication.DEFAULT_ALIGN;
FlashApplication.prototype.application			= null;
FlashApplication.prototype.bgcolor			= FlashApplication.DEFAULT_BGCOLOR;
FlashApplication.prototype.useFABridge			= FlashApplication.DEFAULT_USEFABRIDGE;
FlashApplication.prototype.mergeMode			= FlashApplication.DEFAULT_MERGEMODE;
FlashApplication.prototype.flashvars			= "";

FlashApplication.prototype.requiredMajorVersion		= FlashApplication.DEFAULT_REQUIRED_MAJOR_VERSION;
FlashApplication.prototype.requiredMinorVersion		= FlashApplication.DEFAULT_REQUIRED_MINOR_VERSION;
FlashApplication.prototype.requiredRevision		= FlashApplication.DEFAULT_REQUIRED_REVISION;
/* ! VARS */

/* HANDLERS */
FlashApplication.prototype.onApplicationReady = function()
{
    this.application = FABridge[this.bridgeName].root();

    if (this.mergeMode == FlashApplication.MERGEMODE_FULL)
    {
	for (var m in this.application)
	    if (!this[m])
		this[m] = this.application[m];
    }

    this.dispatchEvent(new Event(Event.COMPLETE, this));
}
/* ! HANDLERS */

/* METHODS */
FlashApplication.prototype.addExtension = function(src, ext)
{
    if (src.indexOf('?') != -1)
	return (src.replace(/\?/, ext+'?'));
    else
	return (src + ext);
}

FlashApplication.prototype.createHTML = function(objAttrs,
						 params,
						 embedAttrs)
{
    var html = '';

    if (FlashDetection.isIE && FlashDetection.isWin
	&& !FlashDetection.isOpera)
    {
	html += '<object ';

  	for (var i in objAttrs)
	    if (objAttrs[i])
  		html += i + '="' + objAttrs[i] + '" ';
	html += '>';

  	for (var i in params)
	    html += '<param name="' + i + '" value="' + params[i] + '" />';
	html += '</object>';
    }
    else
    {
	html = '<embed ';

  	for (var i in embedAttrs)
	    if (embedAttrs[i])
  		html += i + '="' + embedAttrs[i] + '" ';

	html += '/>';
    }

    return (html);
}

FlashApplication.prototype.run = function(myParent)
{
    /* FABridge */
    if (this.useFABridge)
	FABridge.addInitializationCallback(this.bridgeName,
					   this.onApplicationReady.bind(this));
    /* ! FABridge */

    var hasProductInstall	= FlashDetection.detectFlashVersion(6, 0, 65);
    var hasRequestedVersion	= FlashDetection.detectFlashVersion(this.requiredMajorVersion,
								    this.requiredMinorVersion,
								    this.requiredRevision);

    if (hasProductInstall && !hasRequestedVersion)
    {
	this.updateFlashPlayer(myParent);
    }
    else if (hasRequestedVersion)
    {
	// if we've detected an acceptable version
	// embed the Flash Content SWF when all tests are passed
	var flashvars = "bridgeName=" + this.bridgeName + (this.flashvars ? "&" + this.flashvars : "");
	var params = ["src",			this.src,
		      "width",			this.width,
		      "height",			this.height,
		      "align",			this.align,
		      "id",			this.id,
		      "quality",		this.quality,
		      "flashvars",		flashvars,
		      "name",			this.id,
		      "allowScriptAccess",	this.allowScriptAccess,
	              "allowFullscreen",	this.allowFullscreen,
		      "type", 			"application/x-shockwave-flash",
		      "pluginspage", 		"http://www.adobe.com/go/getflashplayer",
		      "wmode", 			this.wmode];

	var ret = this.getArgs(params,
			       ".swf",
			       "movie",
			       "clsid:d27cdb6e-ae6d-11cf-96b8-444553540000",
			       "application/x-shockwave-flash");

	myParent.innerHTML = this.createHTML(ret.objAttrs,
					      ret.params,
					      ret.embedAttrs);
    }
    else
    {
	// flash is too old or we can't detect the plugin
	myParent.innerHTML = this.alternateContent; // insert non-flash content
    }
}

FlashApplication.prototype.updateFlashPlayer = function(myParent)
{
    // DO NOT MODIFY THE FOLLOWING FOUR LINES
    // Location visited after installation is complete if installation is required
    var MMPlayerType = FlashDetection.isIE ? "ActiveX" : "PlugIn";
    var MMredirectURL = window.location;

    document.title = document.title.slice(0, 47) + " - Flash Player Installation";

    var MMdoctitle = document.title;
    var flashvars = "MMredirectURL=" + MMredirectURL + '&MMplayerType='
	+ MMPlayerType + '&MMdoctitle=' + MMdoctitle;

	var params = ["src", 			"/flash/playerProductInstall",
		      "flashvars", 		flashvars,
		      "width", 			this.width,
		      "height", 		this.height,
		      "align", 			"middle",
		      "id", 			this.bridgeName,
		      "quality", 		"high",
		      "name", 			this.bridgeName,
		      "allowScriptAccess",	"sameDomain",
		      "type", 			"application/x-shockwave-flash",
		      "pluginspage", 		"http://www.adobe.com/go/getflashplayer"];

    var ret = this.getArgs(params,
			   ".swf",
			   "movie",
			   "clsid:d27cdb6e-ae6d-11cf-96b8-444553540000",
			   "application/x-shockwave-flash");

    myParent.innerHTML = this.createHTML(ret.objAttrs,
					 ret.params,
					 ret.embedAttrs);
}

FlashApplication.prototype.getArgs = function(args,
					      ext,
					      srcParamName,
					      classid,
					      mimeType)
{
    var ret = new Object();

    ret.embedAttrs = new Object();
    ret.params = new Object();
    ret.objAttrs = new Object();

    for (var i = 0; i < args.length; i = i + 2)
    {
	var currArg = args[i].toLowerCase();

	switch (currArg)
	{
	case "classid":
	    break;
	case "pluginspage":
	    ret.embedAttrs[args[i]] = args[i + 1];
	    break;
	case "src":
	case "movie":
	    args[i+1] = this.addExtension(args[i + 1], ext);
	    ret.embedAttrs["src"] = args[i + 1];
	    ret.params[srcParamName] = args[i + 1];
	    break;
	case "onafterupdate":
	case "onbeforeupdate":
	case "onblur":
	case "oncellchange":
	case "onclick":
	case "ondblClick":
	case "ondrag":
	case "ondragend":
	case "ondragenter":
	case "ondragleave":
	case "ondragover":
	case "ondrop":
	case "onfinish":
	case "onfocus":
	case "onhelp":
	case "onmousedown":
	case "onmouseup":
	case "onmouseover":
	case "onmousemove":
	case "onmouseout":
	case "onkeypress":
	case "onkeydown":
	case "onkeyup":
	case "onload":
	case "onlosecapture":
	case "onpropertychange":
	case "onreadystatechange":
	case "onrowsdelete":
	case "onrowenter":
	case "onrowexit":
	case "onrowsinserted":
	case "onstart":
	case "onscroll":
	case "onbeforeeditfocus":
	case "onactivate":
	case "onbeforedeactivate":
	case "ondeactivate":
	case "type":
	case "codebase":
	    ret.objAttrs[args[i]] = args[i + 1];
	    break;
	case "id":
	case "width":
	case "height":
	case "align":
	case "vspace":
	case "hspace":
	case "class":
	case "title":
	case "accesskey":
	case "name":
	case "tabindex":
	    ret.objAttrs[args[i]] = args[i + 1];
	    ret.embedAttrs[args[i]] = args[i + 1];
	    break;
	default:
	    ret.params[args[i]] = args[i + 1];
	    ret.embedAttrs[args[i]] = args[i + 1];
	}
    }

    ret.objAttrs["classid"] = classid;

    if (mimeType)
	ret.embedAttrs["type"] = mimeType;

    return (ret);
}
/* ! METHODS */