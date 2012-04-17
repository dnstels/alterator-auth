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
      (form-update-value-list '("current_domain") (woo-read-first "/auth"))))
  (form-update-visibility '("warn_message") #t))

(define (ui-init)
    (let ((data (woo-read-first "/auth")))
    (form-update-value-list '("current_domain") data)
    (form-update-enum "domain" (woo-list "/auth/avail_domain"))
    (update-domain)))

;;; UI
(gridbox
    columns "0;100"
    margin 50

    (label text (_ "Current domain:") align "right")
    (label name "current_domain")

    (label colspan 2)

    (label text (_ "Domain list:") align "right")
    (combobox name "domain")
    
    (spacer)
    (edit name "domain_name" visibility #t)
    
    (label colspan 2)
    
	(label colspan 2 name "warn_message" text (_ "WARNING: Changes will take effect after reboot") visibility #f)

    (label colspan 2)
    (if (global 'frame:next)
    (label)
    (hbox align "left"
	(button name "apply" text (_ "Apply") (when clicked (ui-commit)))))
)

;;; Logic

(document:root
  (when loaded
    (ui-init)
    (form-bind "domain" "change" update-domain)))

(frame:on-back (thunk (or (ui-commit) 'cancel)))
(frame:on-next (thunk (or (ui-commit) 'cancel)))
