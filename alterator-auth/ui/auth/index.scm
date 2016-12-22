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
          (check-empty-field "ad_username" (_ "Administrator name"))
          (check-empty-field "ad_password" (_ "Administrator password"))
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
      (form-update-value "ad_password" "")
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
    (if (not (woo-get-option data 'service_winbind))
      (begin
        (winbind-warning visibility #t)
        (ad-group-type   activity   #f)
        (ad-group        activity   #f)))

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

    ;;; ALT domain
    (document:id alt-group-type (radio name "auth-type" value "krb5" text (_ "ALT Linux domain")))

        (document:id alt-group (gridbox columns "0;100" margin 10

        ;;; Warning if avahi-daemon is out of gear
        (document:id avahi-warning (label colspan 2 visibility #f
	     text (string-append (bold (_ "Warning: ")) (_ "Search for domains is impossible because avahi-daemon is not started"))))

        (document:id domain-list-label (label text (_ "Domain list:")))
        (document:id domain-list (combobox name "domain"))

        (edit name "domain_name" visibility #t)
        (checkbox colspan 2 text(_"Use cached credentials for out of domain login") name "ccreds")))

    ;;; Active Directory
    (document:id ad-group-type (radio name "auth-type" value "ad" text (_ "Active Directory domain")))

        (document:id ad-group (gridbox columns "0;100" margin 10

	;;; Warning if task-auth-ad is unavailabe
	(document:id winbind-warning (label colspan 2 visibility #f
	    text (string-append (bold (_ "Warning: ")) (_ "Package task-auth-ad in not installed. Authentication in Active Directory is not available."))))

	(label text (_ "Domain:"))
	(edit name "ad_domain")

	(label text (_ "Workgroup:"))
	(edit name "ad_workgroup")

	(label text (_ "Netbios name:"))
	(edit name "ad_host")

	;; Active Directory administrator authentication
	(label text (_ "Administrator name:"))
	(gridbox columns "33;33;33"
	    (edit name "ad_username" value "Administrator")
	    (label align "right" text (_ "Administrator password:"))
	    (edit name "ad_password" echo "stars"))

    ))

    (spacer)

    (label)

    (groupbox title (_ "Attention: ")
	(label text (_ "Domain change needs reboot for normal operation")))

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
