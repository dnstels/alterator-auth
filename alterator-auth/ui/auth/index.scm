(document:surround "/std/frame")

;;; Functions
(define (update-domain)
  (let ((domain (form-value "domain")))
    (form-update-visibility '("domain_name") (string=? domain "custom"))))

(define (ui-commit)
  (catch/message
    (lambda()
      (apply woo-write
	     "/auth"
	     "ldap_ssl" "on" "auth_type" "krb5" (form-value-list))
      (form-update-value-list '("current_domain") (woo-read-first "/auth")))))

(define (ui-init)
    (let ((data (woo-read-first "/auth")))
    (form-update-value-list '("current_domain" "ccreds") data)

    ;;; Check avahi available for domain lookup
    (woo-catch
        (lambda() (form-update-enum "domain" (woo-list "/auth/avail_domain")))
        (lambda(reason) 
                (avahi-warning visibility #t)
            ))
    (form-update-value "domain" (woo-get-option data 'current_domain))
    (update-domain)))

;;; UI
(gridbox
    columns "0;100"
    margin 50

    (label text (_ "Current domain:") align "right")
    (label name "current_domain")

    (label colspan 2)

    (document:id domain-list-label (label text (_ "Domain list:") align "right"))
    (document:id domain-list (combobox name "domain"))

    ;;; Warning if avahi-daemon is out of gear
    (document:id avahi-warning 
        (label colspan 2 text (string-append (bold (_ "Warning: "))
		 	    							 (_ "Search for domains is impossible because avahi-daemon is not started"))
                         visibility #f))
    (edit name "domain_name" visibility #t)
    (checkbox colspan 2 text(_"Use cached credentials for out of domain login") name "ccreds")    
    (spacer)
    
    (label colspan 2)

	(document:id change-attention 
        (label colspan 2 text (string-append (bold (_ "Attention: "))
		 	                                 (_ "Domain change needs reboot for normal operation"))))

    (label colspan 2)
    (if (global 'frame:next)
    (label)
    (hbox align "left"
	(document:id apply-button (button name "apply" text (_ "Apply") (when clicked (ui-commit))))))
)

;;; Logic

(document:root
  (when loaded
    (ui-init)
    (form-bind "domain" "change" update-domain)))

(frame:on-back (thunk (or (ui-commit) 'cancel)))
(frame:on-next (thunk (or (ui-commit) 'cancel)))
