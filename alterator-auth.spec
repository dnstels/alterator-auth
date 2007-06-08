%define _altdata_dir %_datadir/alterator

Name: alterator-auth
Version: 0.1
Release: alt6

Packager: Stanislav Ievlev <inger@altlinux.org>
BuildArch: noarch

Source:%name-%version.tar

Summary: alterator module for system wide auth settings
License: GPL
Group: System/Configuration/Other
Requires: alterator >= 2.9 gettext
Requires: pam-config >= 1.4.0-alt1.1

BuildPreReq: alterator >= 2.9-alt0.10, alterator-standalone >= 2.5-alt0.3, alterator-fbi >= 0.7-alt1

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
%_var/www/html/*
%_alterator_backend3dir/*

%changelog
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
