%define _altdata_dir %_datadir/alterator

Name: alterator-auth
Version: 0.3
Release: alt1

Packager: Stanislav Ievlev <inger@altlinux.org>
BuildArch: noarch

Source:%name-%version.tar

Summary: alterator module for system wide auth settings
License: GPL
Group: System/Configuration/Other
Requires: alterator >= 2.9 gettext
Requires: pam-config >= 1.4.0-alt1.1
Conflicts: alterator-fbi < 0.15-alt2

BuildPreReq: alterator >= 3.1 alterator-fbi >= 0.7-alt1

# Automatically added by buildreq on Mon Jul 11 2005 (-bi)
BuildRequires: alterator

%description
alterator module for system wide auth settings

%prep
%setup -q

%build
%make_build libdir=%_libdir

%install
%makeinstall HTMLROOT=%buildroot%_var/www/
%find_lang %name

%files -f %name.lang
%_datadir/alterator/applications/*
%_datadir/alterator/ui/*
%_datadir/alterator/help/*/*
%_var/www/html/*
%_alterator_backend3dir/*

%changelog
* Tue Jan 15 2008 Stanislav Ievlev <inger@altlinux.org> 0.3-alt1
- update to new help system

* Thu Jun 14 2007 Stanislav Ievlev <inger@altlinux.org> 0.2-alt2
- fix backend

* Wed Jun 13 2007 Stanislav Ievlev <inger@altlinux.org> 0.2-alt1
- add qt ui
- html ui improvements

* Fri Jun 08 2007 Stanislav Ievlev <inger@altlinux.org> 0.1-alt6
- help improvements from kirill@

* Tue Jun 05 2007 Stanislav Ievlev <inger@altlinux.org> 0.1-alt5
- comment out 'host' option to avoid conflict with uri

* Mon Jun 04 2007 Stanislav Ievlev <inger@altlinux.org> 0.1-alt4
- add help

* Thu May 31 2007 Stanislav Ievlev <inger@altlinux.org> 0.1-alt3
- improve constraints

* Wed May 30 2007 Stanislav Ievlev <inger@altlinux.org> 0.1-alt2
- exclude ldap from list if appropriate nss module doesn't exists

* Tue May 29 2007 Stanislav Ievlev <inger@altlinux.org> 0.1-alt1
- Initial release
