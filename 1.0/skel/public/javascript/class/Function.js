Function.prototype.bind = function (object)
{
    var method = this;

    return (function () {return (method.apply(object, arguments));});
}

Function.prototype.inherits = function(superclass)
{
	var c = function() {};

	c.prototype = superclass.prototype;
	this.prototype = new c();
}
