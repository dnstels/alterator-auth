(define-module (ui auth ajax)
    :use-module (alterator woo)
    :use-module (alterator ajax)
    :export (init))

(define (update-domain)
    (let ((domain (form-value "domain")))
    (form-update-visibility '("domain_name") (string=? domain "custom"))))

(define (ui-init)
    (let ((data (woo-read-first "/auth")))
    (form-update-value-list '("current_domain") data)
    (form-update-enum "domain" (woo-list "/auth/avail_domain"))
    (update-domain)))

(define (init)
    (ui-init)
    (form-bind "domain" "change" update-domain))
