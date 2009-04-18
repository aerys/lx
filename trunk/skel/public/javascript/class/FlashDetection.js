function FlashDectecton()
{
}

FlashDetection.isIE	= (navigator.appVersion.indexOf("MSIE") != -1) ? true : false;
FlashDetection.isWin	= (navigator.appVersion.toLowerCase().indexOf("win") != -1) ? true : false;
FlashDetection.isOpera	= (navigator.userAgent.indexOf("Opera") != -1) ? true : false;

FlashDetection.controlVersion = function()
{
    var version;
    var axo;
    var e;

    // NOTE : new ActiveXObject(strFoo) throws an exception if strFoo isn't in the registry

    try
    {
	// version will be set for 7.X or greater players
	axo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash.7");
	version = axo.GetVariable("$version");
    }
    catch (e)
    {
	// NOTHING
    }

    if (!version)
    {
	try
	{
	    // version will be set for 6.X players only
	    axo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash.6");

	    // installed player is some revision of 6.0
	    // GetVariable("$version") crashes for versions 6.0.22 through 6.0.29,
	    // so we have to be careful.

	    // default to the first public version
	    version = "WIN 6,0,21,0";

	    // throws if AllowScripAccess does not exist (introduced in 6.0r47)
	    axo.AllowScriptAccess = "always";

	    // safe to call for 6.0r47 or greater
	    version = axo.GetVariable("$version");

	}
	catch (e)
	{
	    // NOTHING
	}
    }

    if (!version)
    {
	try
	{
	    // version will be set for 4.X or 5.X player
	    axo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash.3");
	    version = axo.GetVariable("$version");
	}
	catch (e)
	{
	    // NOTHING
	}
    }

    if (!version)
    {
	try
	{
	    // version will be set for 3.X player
	    axo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash.3");
	    version = "WIN 3,0,18,0";
	}
	catch (e)
	{
	    // NOTHING
	}
    }

    if (!version)
    {
	try
	{
	    // version will be set for 2.X player
			axo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash");
	    version = "WIN 2,0,0,11";
	}
	catch (e)
	{
	    version = -1;
	}
    }

    return (version);
}

FlashDetection.getSwfVersion = function()
{
    // NS/Opera version >= 3 check for Flash plugin in plugin array
    var flashVer = -1;

	if (navigator.plugins != null && navigator.plugins.length > 0)
    {
	if (navigator.plugins["Shockwave Flash 2.0"] || navigator.plugins["Shockwave Flash"])
	{
	    var swVer2 = navigator.plugins["Shockwave Flash 2.0"] ? " 2.0" : "";
	    var flashDescription = navigator.plugins["Shockwave Flash" + swVer2].description;
	    var descArray = flashDescription.split(" ");
	    var tempArrayMajor = descArray[2].split(".");
	    var versionMajor = tempArrayMajor[0];
	    var versionMinor = tempArrayMajor[1];
	    var versionRevision = descArray[3];

	    if (versionRevision == "")
				versionRevision = descArray[4];
	    if (versionRevision[0] == "d")
		versionRevision = versionRevision.substring(1);
	    else if (versionRevision[0] == "r")
	    {
		versionRevision = versionRevision.substring(1);
		if (versionRevision.indexOf("d") > 0)
		    versionRevision = versionRevision.substring(0, versionRevision.indexOf("d"));
	    }
	    else if (versionRevision[0] == "b")
		versionRevision = versionRevision.substring(1);

	    var flashVer = versionMajor + "." + versionMinor + "." + versionRevision;
	}
    }
    // MSN/WebTV 2.6 supports Flash 4
    else if (navigator.userAgent.toLowerCase().indexOf("webtv/2.6") != -1)
	flashVer = 4;
    // WebTV 2.5 supports Flash 3
    else if (navigator.userAgent.toLowerCase().indexOf("webtv/2.5") != -1)
	flashVer = 3;
    // older WebTV supports Flash 2
    else if (navigator.userAgent.toLowerCase().indexOf("webtv") != -1)
	flashVer = 2;
    else if (FlashDetection.isIE && FlashDetection.isWin
	     && !FlashDetection.isOpera )
	flashVer = FlashDetection.controlVersion();

    return (flashVer);
}

FlashDetection.detectFlashVersion = function(reqMajorVer, reqMinorVer, reqRevision)
{
    var versionStr = FlashDetection.getSwfVersion();

    if (versionStr == -1 )
	return (false);
    else if (versionStr != 0)
    {
	if (FlashDetection.isIE && FlashDetection.isWin
	    && !FlashDetection.isOpera) {
	    // Given "WIN 2,0,0,11"
	    tempArray         = versionStr.split(" "); 	// ["WIN", "2,0,0,11"]
	    tempString        = tempArray[1];			// "2,0,0,11"
	    versionArray      = tempString.split(",");	// ['2', '0', '0', '11']
	}
	else
	{
	    versionArray      = versionStr.split(".");
	}
	var versionMajor      = versionArray[0];
	var versionMinor      = versionArray[1];
	var versionRevision   = versionArray[2];

        // is the major.revision >= requested major.revision AND the minor version >= requested minor
	if (versionMajor > parseFloat(reqMajorVer))
	    return (true);
	else if (versionMajor == parseFloat(reqMajorVer))
	{
	    if (versionMinor > parseFloat(reqMinorVer))
		return (true);
	    else if (versionMinor == parseFloat(reqMinorVer))
	    {
		if (versionRevision >= parseFloat(reqRevision))
		    return (true);
	    }
	}
	return (false);
    }
}