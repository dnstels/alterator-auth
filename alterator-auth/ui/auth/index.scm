(document:surround "/std/base")
(document:insert "/std/functions")

(document:envelop with-translation _ "alterator-auth")

;;; functions

(define *profiles* (make-cell '()))

(define (default-profile current)
  (or  (list-index (lambda(x) (string=? (car x) current))
		   (cell-ref *profiles*))
       0))

(define (current-profile)
  (car (list-ref (cell-ref *profiles*)
		 (profile-id current))))

(define (view-profile)
  (let ((is-ldap (string=? (current-profile) "ldap")))
    ((widgets ldap-header
	      ldap-uri
              ldap-basedn
              ldap-uri-label
              ldap-basedn-label
	      ldap-apply) visibility is-ldap)))

(define (change-profile)
  (woo-catch/message
    (thunk
      (woo-write "/auth" 'profile (current-profile))
      (view-profile))))

(define (write-profile)
  (woo-catch/message
    (thunk
      (let ((profile-type (current-profile)))
	(and (string=? profile-type "ldap")
	     (woo-write/constraints "/auth"
				    'ldap_uri (ldap-uri text)
				    'ldap_basedn (ldap-basedn text)))))))

;;; UI
(gridbox
  columns "10;30;50;10"

  (spacer)
  (hbox colspan 2
	align "left"
	(label (bold (_ "Auth type")))
	(document:id profile-id (combobox rows '("ldap" "local")))
	(label "")
	(document:id change-button (button (_ "Change") (when clicked (change-profile)))))
  (spacer)

  (spacer)
  (document:id ldap-header (label (bold (_ "LDAP settings")) align "left" colspan 2))
  (spacer)

  (spacer)
  (document:id ldap-uri-label (label (_ "LDAP server")))
  (document:id ldap-uri (edit ""))
  (spacer)

  (spacer)
  (document:id ldap-basedn-label (label (_ "Base DN")))
  (document:id ldap-basedn (edit ""))
  (spacer)

  (spacer)
  (label "" colspan 2)
  (spacer)

  (spacer)
  (document:id ldap-apply (button (_ "Save settings") align "left" (when clicked (write-profile))))
  (spacer)
  (spacer))

;;; logic

(document:root (when loaded
		 (woo-catch/message
		   (thunk
		     (let ((avail (woo-list/name+label "/auth/avail_profile"))
			   (data (woo-read-first "/auth")))

		       ;;additional ldap settings
		       (ldap-uri text (woo-get-option data 'ldap_uri))
		       (ldap-basedn text (woo-get-option data 'ldap_basedn))

		       (cell-set! *profiles* avail)
		       (profile-id rows (map cdr avail)
				   current (default-profile (woo-get-option data 'profile)))
		       (view-profile))))))

