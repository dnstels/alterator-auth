(document:surround "/std/base")
(document:insert "/std/functions")

(document:envelop with-translation _ "alterator-auth")

;;; Functions

(define *profiles* (make-cell '()))

(define (list-profile)
  (woo-catch/message
    (thunk
      (let ((avail (woo-list/name+label "/auth/avail_profile")))
	(cell-set! *profiles* avail)
	(profile-id rows (map cdr avail))))))

(define (profile-index current)
  (or  (list-index (lambda(x) (string=? (car x) current))
		   (cell-ref *profiles*))
       0))

(define (current-profile)
  (car (list-ref (cell-ref *profiles*)
		 (profile-id current))))

(define (read-profile)
  (woo-catch/message
    (thunk
      (let ((data (woo-read-first "/auth")))
	(ldap-uri text (woo-get-option data 'ldap_uri))
	(ldap-basedn text (woo-get-option data 'ldap_basedn))
	(profile-id current (profile-index (woo-get-option data 'profile)))
	(view-profile)))))

(define (view-profile)
  (let ((is-ldap (string=? (current-profile) "ldap")))
    ((widgets ldap-uri
	      ldap-basedn
	      ldap-uri-label
	      ldap-basedn-label) visibility is-ldap)))

(define (write-profile)
  (woo-catch/message
    (thunk
      (woo-write/constraints "/auth"
			     'profile (current-profile)
			     'ldap_uri (ldap-uri text)
			     'ldap_basedn (ldap-basedn text)))))

;;; UI
(gridbox
  columns "10;0;80;10"

  (spacer)
  (label text (_ "Auth type:") align "right")
  (document:id profile-id (combobox (when selected (view-profile))))
  (spacer)

  (label colspan 4)

  (spacer)
  (document:id ldap-uri-label (label text (_ "LDAP server:") align "right"))
  (document:id ldap-uri (edit))
  (spacer)

  (spacer)
  (document:id ldap-basedn-label (label text (_ "Base DN:") align "right"))
  (document:id ldap-basedn (edit))
  (spacer)

  (label colspan 4)

  (spacer)
  (spacer)
  (hbox align "left"
	(button text (_ "Apply") (when clicked (write-profile)))
	(button text (_ "Reset") (when clicked (read-profile))))
  (spacer))

;;; Logic

(document:root
  (when loaded
    (and (list-profile) (read-profile))))
