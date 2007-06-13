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
  (let ((profile-type (current-profile)))
    (cond
     ((string=? profile-type "local")
      (local-type visibility #t)
      (ldap-type visibility #f))
     ((string=? profile-type "ldap")
      (local-type visibility #f)
      (ldap-type visibility #t)))))

(define (write-profile)
  (woo-catch/message
   (thunk
    (let ((profile-type (current-profile)))
      (cond
       ((string=? profile-type "local")
        (woo-write "/auth" 'profile profile-type))
       ((string=? profile-type "ldap")
        (woo-write "/auth"
                   'profile profile-type
                   'ldap_uri (ldap-uri text)
                   'ldap_basedn (ldap-basedn text))))))))

;;; UI

margin 10

(gridbox
 columns "10;30;50;10"
 max-height 30
 (spacer)
 (label (bold (_ "Auth type")))
 (document:id profile-id (combobox rows '("ldap" "local")))
 (spacer))

(document:id local-type (vbox (label "")))
(document:id ldap-type
             (gridbox columns "10;30;50;10"

                      (spacer)
                      (label (bold (_ "LDAP server")))
                      (document:id ldap-uri (edit "b"))
                      (spacer)
                      
                      (spacer)
                      (label (bold (_ "Base DN")))
                      (document:id ldap-basedn (edit "d"))
                      (spacer)))

(vbox (label "")) ;;zerg's spacer

(hbox (document:id apply-button (button (_ "Apply")))
      (button (_ "Quit") (when clicked (document:end))))

;;; logic

(document:root (when loaded
                 (woo-catch/message
                  (thunk
		   (apply-button (when clicked (write-profile)))
                   (let ((avail (woo-list/name+label "/auth/avail_profile"))
                         (data (woo-read-first "/auth")))

                     ;;additional ldap settings
                     (ldap-uri text (woo-get-option data 'ldap_uri))
                     (ldap-basedn text (woo-get-option data 'ldap_basedn))
                     
                     (cell-set! *profiles* avail)
                     (profile-id rows (map cdr avail)
                                 current (default-profile (woo-get-option data 'profile))
                                 (when selected (view-profile))
                                 selected))))))
