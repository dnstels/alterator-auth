(document:surround "/std/base")
(document:insert "/std/functions")

(document:envelop with-translation _ "alterator-auth")

;;; Functions
(define (read-profile)
  (woo-catch/message
    (thunk
      (profile-id enumref "/auth/avail_profile")
      (let ((data (woo-read-first "/auth")))
	(ldap-uri value (woo-get-option data 'ldap_uri))
	(ldap-basedn value (woo-get-option data 'ldap_basedn))
	(profile-id value (woo-get-option data 'profile))))))

(define (write-profile)
  (woo-catch/message
    (thunk
      (woo-write/constraints "/auth"
			     'profile (profile-id value)
			     'ldap_uri (ldap-uri value)
			     'ldap_basedn (ldap-basedn value)))))

;;; UI
(gridbox
  columns "10;0;80;10"

  (spacer)
  (label text (_ "Auth type:") align "right")
  (document:id profile-id (combobox name "profile"))
  (spacer)

  (label colspan 4)

  (spacer)
  (document:id ldap-uri-label (label text (_ "LDAP server:") align "right" name "ldap_uri" visibility #f))
  (document:id ldap-uri (edit name "ldap_uri" visibility #f))
  (spacer)

  (spacer)
  (document:id ldap-basedn-label (label text (_ "Base DN:") align "right" name "ldap_basedn" visibility #f))
  (document:id ldap-basedn (edit name "ldap_basedn" visibility #f))
  (spacer)

  (label colspan 4)

  (spacer)
  (spacer)
  (hbox align "left"
	(button text (_ "Apply") (when clicked (write-profile)))
	(button text (_ "Reset") (when clicked (read-profile) (effect-update))))
  (spacer))

;;; Logic

(effect-show "ldap_uri" "profile" "ldap")
(effect-show "ldap_basedn" "profile" "ldap")

(document:root
  (when loaded
    (and (read-profile) (effect-init))))
