(document:surround "/std/frame")

;;; Logic
(define (ui-write)
  (document:end (form-value-list '("admin_username" "admin_password"))))

;;; Default administrator name for domain types
(define (get-admin-name type)
  (if (string=? type "ad")
      "Administrator"
      (if (string=? type "freeipa")
          "admin"
          "")))

;;; Init dialog
(define (ui-init)
  (form-update-value "admin_username" (get-admin-name (global 'domain-type)))
  (form-bind "ok" "click" ui-write)
  (form-bind "cancel" "click" document:end))

;;; UI
(gridbox columns "0;0;100" margin 25 spacing 10
    (label align "center" rowspan 4 text " ")
    (label colspan 2 text (string-append (_ "Enter the name and password of an account") "\n" (_ "with permission to join the domain.")))
    (label text (_ "Username:"))
    (edit name "admin_username")
    (label text (_ "Password:"))
    (edit name "admin_password" echo "stars")
    (hbox colspan 2 align "left"
      (button name "ok" text (_ "OK"))
	  (button name "cancel" text (_ "Cancel"))))

;;; initialization
(document:root (when loaded (ui-init)))
