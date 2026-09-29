(define-module (my-packages scripts)
  #:use-module (guix packages)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:export (my-scripts))

(define-public my-scripts
  (package
    (name "my-scripts")
    (version "1.0")
    ;; Путь относительный от ЭТОГО файла (my-packages/scripts.scm)
    ;; ../scripts -> ~/config/scripts/
    (source (local-file "../scripts" #:recursive? #t))
    (build-system trivial-build-system)
    (arguments
     (list
      #:modules '((guix build utils))
      #:builder
      #~(begin
          (use-modules (guix build utils))
          (let ((bin (string-append #$output "/bin")))
            (mkdir-p bin)
            (for-each
             (lambda (file)
               (let ((target (string-append bin "/" (basename file))))
                 (copy-file file target)
                 (chmod target #o555)))  ; r-xr-xr-x, исполняемый
             (find-files #$source (const #t)))))))
    (home-page #f)
    (synopsis "Personal scripts")
    (description "Collection of personal utility scripts.")
    (license #f)))
