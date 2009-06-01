lx = {};

lx._parameters = null;

$ = function(myId)
{
    return (document.getElementById(myId));
}

/*lx.import = function(myClass)
{
    var head	= document.getElementsByTagName('head')[0];
    var script	= document.createElement('script');

    script.setAttribute('language', 'javascript');
    script.setAttribute('type', 'text/javascript');
    script.setAttribute('src', '/javascript/class/' + myClass);

    head.appendChild(script);
}*/

lx.getParameter = function(myName)
{
	if (lx._parameters == null)
	{
		var params = window.location.href.split("?");
		
		if (params.length == 2)
			params = params[1].split("&");
		
		lx._parameters = {};
		for (var i in params)
		{
			var value = params[i].split("="); 
			
			lx._parameters[value[0]] = value[1];
		}
	}
	
	return (lx._parameters[myName]);
}