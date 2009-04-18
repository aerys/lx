Function.prototype.bind = function (object)
{
    var method = this;

    return (function () {return (method.call(object, arguments));});
}

Function.prototype.inherits = function(superclass)
{
	var c = function() {};

	c.prototype = superclass.prototype;
	this.prototype = new c();
}
