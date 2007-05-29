function initAuth()
{
    var elem = document.getElementById('auth-select');
    if (elem)  addEvent(elem,'change',function(){ elem.form.submit(); });
}

addEvent(window,"load",initAuth);
