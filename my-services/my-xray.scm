;; ~/config/services/my-xray.scm

(define-module (services my-xray)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:export (my-xray-service))

(define (my-xray-service)
  (simple-service 'my-xray home-shepherd-service-type
    (list
     (shepherd-service
      (documentation "my-xray: local xray-core")
      (provision '(my-xray))
      (requirement '())
      (start #~(make-forkexec-constructor
                (list (string-append (getenv "HOME") "/programs/xray")
                      "run" "-c"
                      (string-append (getenv "HOME") "/config/xray/config.json"))))
      (stop #~(make-kill-destructor))))))
