function GoogleAnalytics(myId)
{
    var script	= document.createElement("script");
    var src	= ("https:" == document.location.protocol) ? "https://ssl." : "http://www."
	          + "google-analytics.com/ga.js";
    var head	= document.getElementsByTagName("head")[0];

    this._id = myId;

    script.setAttribute("type", "text/javascript");
    script.setAttribute("src", src);
    head.appendChild(script);
}

GoogleAnalytics.DEFAULT_TIMEOUT		= 100;

GoogleAnalytics.prototype._id		= null;

GoogleAnalytics.prototype.trackPageView = function()
{
    try
    {
	var tracker = _gat._getTracker(this._id);

	tracker._trackPageview();
    }
    catch (e)
    {
	if (e instanceof ReferenceError)
	{
	    setTimeout(this.trackPageView.bind(this),
		       GoogleAnalytics.DEFAULT_TIMEOUT);
	}
    }

}