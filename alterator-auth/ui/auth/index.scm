(document:surround "/std/frame")

;;; Functions
(define (update-domain)
  (let ((domain (form-value "domain")))
    (form-update-visibility '("domain_name") (string=? domain "custom"))))

;;; Show warning if field is empty
(define (check-empty-field field name)
  (if (string=? (form-value field) "")
      (woo-error (string-append (_ "Please, fill field ") name))))

;;; Check netbios name lenght
(define (check-netbios-name)
  (if (> (string-length (form-value "ad_host")) 15)
      (woo-error (_ "Netbios name should not be more 15 chars"))))

;;; Check for empty values if Active Directory setting up
(define (ad-check-values)
  (if (string=? (form-value "auth-type") "ad")
      (begin
          (check-empty-field "ad_domain"   (_ "Domain"))
          (check-empty-field "ad_host"     (_ "Netbios name"))
          (check-netbios-name))))

(define (ui-commit)
  (catch/message
    (lambda()
      (ad-check-values)
      (apply woo-write
	     "/auth"
	     "ldap_ssl" "on"
	     "auth_type" (form-value "auth-type")
	     (form-value-list))
      (form-update-value-list '("current_domain") (woo-read-first "/auth")
      (document:popup-information (string-append (_ "Welcome to the ") (form-value "ad_domain") (_ " domain.")) 'ok)))))

(define (ui-init)
    (let ((data (woo-read-first "/auth")))
    (form-update-value-list '("current_domain" "ccreds") data)

    ;;; Check avahi available for domain lookup
    (woo-catch
        (lambda() (form-update-enum "domain" (woo-list "/auth/avail_domain")))
        (lambda(reason)
                (avahi-warning visibility #t)
            ))
    ;;; show warnings
    (if (not (woo-get-option data 'service_avahi))
      (begin
        (avahi-warning  visibility  #t)
        (alt-group-type activity    #f)
        (alt-group      activity    #f)))
    (if (not (woo-get-option data 'type_ad_available))
      (begin
        (type-ad-warning visibility #t)
        (ad-group-type   activity   #f)
        (ad-group        activity   #f)))
    (if (not (woo-get-option data 'type_freeipa_available))
      (begin
        (type-freeipa-warning visibility #t)
        (freeipa-group-type   activity   #f)
        (freeipa-group        activity   #f)))

    ;;; fill fields
    (form-update-value "domain" (woo-get-option data 'current_domain))

    (form-update-value "auth-type"    (woo-get-option data 'auth_type))
    (form-update-value "ad_domain"    (woo-get-option data 'ad_domain))
    (form-update-value "ad_host"      (woo-get-option data 'ad_host))
    (form-update-value "ad_workgroup" (woo-get-option data 'ad_workgroup))

    ;;; Fill fields
    (if (string=? (form-value "ad_host") "")
        (form-update-value "ad_host" (woo-get-option data 'hostname)))

    (update-domain)

    ))

;;; UI
(gridbox
    columns "100"
    margin 50


    (label text (_ "Current domain:") align "right" visibility #f)
    (label name "current_domain" visibility #f)

    ;;; Local database
    (radio name "auth-type" value "local" text (_ "Local database") state #t)
    (label)

    ;;; ALT domain
    (document:id alt-group-type (radio name "auth-type" value "krb5" text (_ "ALT Linux domain")))

      (document:id alt-group (gridbox columns "0;0;50;50" spacing 5

	;;; Warning if avahi-daemon is out of gear
        (document:id avahi-warning (gridbox colspan 4 columns "0;100" visibility #f (label text "   ") (label
          text (string-append (bold (_ "Warning: ")) (_ "Search for domains is impossible because avahi-daemon is not started")))))

        (label text "   ")
        (document:id domain-list-label (label text (_ "Domain list:")))
        (document:id domain-list (combobox name "domain"))
	(spacer)

        (spacer colspan 2)
        (edit "domain_name" visibility #f)
	(spacer)

        (spacer)
        (checkbox colspan 3 text(_"Use cached credentials for out of domain login") name "ccreds")))
    (label)

    ;;; Active Directory
    (document:id ad-group-type (radio name "auth-type" value "ad" text (_ "Active Directory domain")))

      (document:id ad-group (gridbox columns "0;0;50;50" spacing 5

        ;;; Warning if task-auth-ad and task-auth-ad-sssd is unavailable
        (document:id type-ad-warning (gridbox colspan 4 columns "0;100" visibility #f (label text "   ") (label
            text (string-append (bold (_ "Warning: ")) (_ "Neither task-auth-ad nor task-auth-ad-sssd is installed. Authentication in Active Directory is not available.")))))

        (label text "   ")
        (label text (_ "Domain:"))
        (edit name "ad_domain")
	(spacer)

	(spacer)
        (label text (_ "Workgroup:"))
        (edit name "ad_workgroup")
	(spacer)

	(spacer)
        (label text (_ "Computer name:"))
        (edit name "ad_host")
	(spacer)
        ))
    (label)

    ;;; FreeIPA
    (document:id freeipa-group-type (radio name "auth-type" value "freeipa" text (_ "FreeIPA domain")))

      (document:id freeipa-group (gridbox columns "0;0;50;50" spacing 5

        ;;; Warning if task-auth-freeipa is unavailable
        (document:id type-freeipa-warning (gridbox colspan 4 columns "0;100" visibility #f (label text "   ") (label
            text (string-append (bold (_ "Warning: ")) (_ "Package task-auth-freeipa is not installed. Authentication in FreeIPA is not available.")))))

        (label text "   ")
        (label text (_ "Domain:"))
        (edit name "freeipa_domain")
	(spacer)

	(spacer)
        (label text (_ "Computer name:"))
        (edit name "freeipa_host")
	(spacer)
        ))

    (spacer)
    (label)

    (groupbox columns "100" title (_ "Attention: ")
	(label text (bold (_ "Domain change needs reboot for normal operation"))))

    (label)
    (if (global 'frame:next)
    (label)
    (hbox align "left"
	(document:id apply-button (button name "apply" text (_ "Apply") (when clicked (ui-commit))))))
)

;;; Logic

(document:root
  (when loaded
    (ui-init)
    (form-bind "auth-type" "change" update-domain)
    (form-bind "domain" "change" update-domain)))

(frame:on-back (thunk (or (ui-commit) 'cancel)))
(frame:on-next (thunk (or (ui-commit) 'cancel)))
