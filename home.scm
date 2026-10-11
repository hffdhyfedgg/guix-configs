;; ~/config/home.scm

(eval-when (expand load eval)
  (add-to-load-path (dirname (current-filename))))

(use-modules
    (guix gexp)
    (gnu home)
    (gnu home services)
    (gnu home services shells)
    (gnu home services fontutils)
    (gnu home services syncthing)
    (gnu packages librewolf)
    (gnu packages xfce)
    (gnu packages admin)
    (gnu packages text-editors)
    (gnu packages fonts)
    (gnu packages xdisorg)
    (gnu packages password-utils)
    (gnu packages version-control)
    (gnu packages shellutils)
    (gnu packages terminals)
    (gnu packages rust-apps)
    (gnu packages base)
    (gnu packages search)
    (my-packages scripts)
    ; (my-services my-xray) ; не работает
    )

(home-environment
  (packages
   (list

       ; Консольный ИП
       starship atuin fzf
       zsh-autosuggestions zsh-syntax-highlighting
       fzf-tab zsh-completions direnv
       ; Консольные утилитыe
       eza sd fd trash-cli ripgrep bat plocate zoxide
       ; Программирование: ПО
       ; Программирование: наборы разработчиков

       ; Другое
       my-scripts
    ))

  (services
   (list
    (service home-xdg-configuration-files-service-type
     `(
       ("zed/settings.json" ,(local-file "zed/settings.json"))
       ("starship.toml" ,(local-file "starship/starship.toml"))
       ("guix/channels.scm" ,(local-file "guix/channels.scm"))
       ))



        (simple-service 'my-template-symlink
                        home-files-service-type
                        (list
                        ;; list, а НЕ cons!
                        (list "Шаблоны"
                              (local-file "templates" #:recursive? #t))))


    (simple-service 'my-env-vars
                    home-environment-variables-service-type
                    ;; XDG_DATA_HOME видимо выставляет кто-то другой. В консоли он есть.
                    ;; ИСПРАВЛЕНО: ru_RU.UTF-8 вместо utf8 для корректной работы Qt/GTK
                    '(("LANG"                . "ru_RU.UTF-8")
                      ("LC_ALL"              . "ru_RU.UTF-8")
                      ("LC_CTYPE"            . "ru_RU.UTF-8")
                      ; ("XDG_SESSION_TYPE"    . "wayland")
                      ; ("XDG_CURRENT_DESKTOP" . "wlroots")
                      ))

    (service home-zsh-service-type
             (home-zsh-configuration
              (zshrc (list (local-file "zsh/zshrc")))
              (zshenv (list (local-file "zsh/zshenv")))
              (zprofile (list (local-file "zsh/zprofile")))
              (zlogin (list (local-file "zsh/zlogin")))))

    ); list
   ); services
  )


