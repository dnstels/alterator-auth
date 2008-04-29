function authAdjust(select,divs)
{
    var value = select.value;
    for (var i=0;i<divs.length;++i)
    {
	var f = divs[i];
	var type = f.getAttribute("case");
	if (type && type != value)
	    f.style.display = "none";
	else
	    f.style.display = "block";
    }
}

function initAuthSelect()
{
    var change = document.getElementById("auth-change");
    if (change) change.style.display="none";

    var select = document.getElementById("auth-select");
    var divs = document.getElementsByTagName("div");
    if (select && divs)
	addEvent(select,'change', function() { authAdjust(select,divs); });
}

addEvent(window,'load',initAuthSelect);
