(document:surround "/std/base")
(document:insert "/std/functions")

;;; Functions
(define (read-domain)
  (catch/message
    (lambda()
      (domain-id enumref "/auth/avail_domain")
      (let ((data (woo-read-first "/auth")))
    (current-id text (woo-get-option data 'current_domain))
	))))

(define (write-domain)
  (catch/message
    (lambda()
      (woo-write "/auth"
		 'domain (domain-id value)
		 'domain_name (domain-name value)))))

;;; UI
(gridbox
  columns "0;100"
  margin 50

  (label text (_ "Current domain:") align "right")
  (document:id current-id (label))

  (label colspan 2)

  (label text (_ "Domain list:") align "right")
  (document:id domain-id (combobox name "domain"))

  (label colspan 2)

  (label text (_ "Enter Domain:") align "right" name "domain_name")
  (document:id domain-name (edit name "domain_name"))


  (label colspan 4)

  (spacer)
  (hbox align "left"
	(button text (_ "Apply") (when clicked (write-domain)))))

;;; Logic

(document:root
  (when loaded
    (read-domain)))

