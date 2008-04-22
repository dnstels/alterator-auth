function authAdjust(select,forms)
{
    var value = select.value;
    for (var i=0;i<forms.length;++i)
    {
	var f = forms[i];
	var type = f.getAttribute("case");
	if (type && type != value)
	    f.style.display = "none";
	else
	    f.style.display = "block";
	if (f["profile"] != select) f["profile"].value = value;
    }
}

function initAuthSelect()
{
    var change = document.getElementById("auth-change");
    if (change) change.style.display="none";

    var select = document.getElementById("auth-select");
    var forms = document.getElementsByTagName("form");
    if (select && forms) addEvent(select,'change', function() { authAdjust(select,forms); });
}

addEvent(window,'load',initAuthSelect);
