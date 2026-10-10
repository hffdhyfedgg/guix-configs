(define-module (nginx-service)
  #:use-module (gnu services)
  #:use-module (gnu services web)
  #:use-module (guix gexp)
  #:export (make-default-nginx-service))

;;; Пример модуля: обёртка над стандартным nginx-service-type,
;;; чтобы не держать конфиг в os.scm.
;;;
;;; Использование в os.scm:
;;;   (add-to-load-path "./services")
;;;   (use-modules (nginx-service))
;;;   ...
;;;   (services (cons (make-default-nginx-service) %base-services))

(define (make-default-nginx-service)
  (service nginx-service-type
    (nginx-configuration
     (server-blocks
      (list
       (nginx-server-configuration
        (listen '("80"))
        (server-name '("localhost"))
        (root "/srv/www")
        (locations
         (list
          (nginx-location-configuration
           (uri "/")
           (body '("return 200 'hello from guix system container\\n';")))))))))))
