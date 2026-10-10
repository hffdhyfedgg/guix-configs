(define-module (example-app-service-type)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (gnu packages base)
  #:export (example-app-service-type
            example-app-configuration
            example-app-configuration?
            example-app-configuration-log-file))

;; Пример конфигурации сервиса.
;; Если сервису нужны параметры, опишите их как record.

(define-record-type* <example-app-configuration>
  example-app-configuration make-example-app-configuration
  example-app-configuration?
  (log-file example-app-configuration-log-file
            (default "/var/log/example-app.log")))

(define (example-app-shepherd-service config)
  (let ((log-file (example-app-configuration-log-file config)))
    (shepherd-service
     (documentation "Example application")
     (provision '(example-app))
     (requirement '(networking))
     (start #~(make-forkexec-constructor
               (list #$(file-append coreutils "/bin/sh")
                     "-c"
                     (string-append
                      "while true; do echo running >> "
                      #$log-file
                      "; sleep 5; done"))
               #:log-file log-file))
     (stop #~(make-kill-destructor)))))

(define example-app-service-type
  (service-type
   (name 'example-app)
   (extensions
    (list
     (service-extension shepherd-root-service-type
                        (lambda (config)
                          (list (example-app-shepherd-service config))))))
   (default-value (example-app-configuration))))
