(document:surround "/std/base")
(document:insert "/std/functions")

(document:envelop with-translation _ "alterator-auth")

;;; Functions
(define (read-profile)
  (catch/message
    (lambda()
      (profile-id enumref "/auth/avail_profile")
      (let ((data (woo-read-first "/auth")))
	(ldap-host value (woo-get-option data 'ldap_host))
	(ldap-port value (woo-get-option data 'ldap_port))
	(ldap-ssl value (woo-get-option data 'ldap_ssl))
	(ldap-basedn value (woo-get-option data 'ldap_basedn))
	(profile-id value (woo-get-option data 'profile))))))

(define (write-profile)
  (catch/message
    (lambda()
      (woo-write "/auth"
		 'profile (profile-id value)
		 'ldap_host (ldap-host value)
		 'ldap_port (ldap-port value)
		 'ldap_ssl (ldap-ssl value)
		 'ldap_basedn (ldap-basedn value)))))

;;; UI
(gridbox
  columns "0;100"
  margin 50

  (label text (_ "Auth type:") align "right")
  (document:id profile-id (combobox name "profile"))

  (label colspan 2)

  (label text (_ "LDAP server:") align "right" name "ldap_host" visibility #f)
  (document:id ldap-host (edit name "ldap_host" visibility #f))

  (document:id ldap-basedn-label (label text (_ "Base DN:") align "right" name "ldap_basedn" visibility #f))
  (document:id ldap-basedn (edit name "ldap_basedn" visibility #f))

  (label text (_ "Port (optional):") align "right" name "ldap_port" visibility #f)
  (document:id ldap-port (edit name "ldap_port" visibility #f))

  (spacer)
  (document:id ldap-ssl (checkbox  text (_ "Enable TLS/SSL") name "ldap_ssl" visibility #f))

  (label colspan 4)

  (spacer)
  (hbox align "left"
	(button text (_ "Apply") (when clicked (write-profile)))
	(button text (_ "Reset") (when clicked (read-profile) (update-effect)))))

;;; Logic

(effect-show "ldap_host" "profile" "ldap")
(effect-show "ldap_port" "profile" "ldap")
(effect-show "ldap_ssl" "profile" "ldap")
(effect-show "ldap_basedn" "profile" "ldap")

(document:root
  (when loaded
    (and (read-profile) (init-effect))))
