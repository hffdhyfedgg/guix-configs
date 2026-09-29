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
       ; Программы
       librewolf
       keepassxc
       ; ГИП
       btop
       fuzzel
       ; Консольный ИП
       starship zoxide atuin fzf
       zsh-autosuggestions zsh-syntax-highlighting
       fzf-tab zsh-completions
       ; Консольные утилитыe
       eza sd fd trash-cli ripgrep bat plocate
       ; Программирование: ПО
       git
       zed
       ; Программирование: наборы разработчиков

       ; Другое
       my-scripts
       font-nerd-jetbrains-mono
    ))

  (services
   (list
    (service home-xdg-configuration-files-service-type
     `(("labwc/autostart"   ,(local-file "labwc/autostart"))
       ("labwc/environment" ,(local-file "labwc/environment"))
       ("labwc/rc.xml"      ,(local-file "labwc/rc.xml"))
       ("waybar/config"     ,(local-file "waybar/config"))
       ("waybar/style.css"  ,(local-file "waybar/style.css"))
       ("sway/config"       ,(local-file "sway/config"))
       ("fuzzel/fuzzel.ini" ,(local-file "fuzzel/fuzzel.ini"))
       ("zed/settings.json" ,(local-file "zed/settings.json"))
       ("starship.toml" ,(local-file "starship/starship.toml"))
       ))

    (simple-service 'my-fonts
        home-fontconfig-service-type
        (list
         '(alias
          (family "monospace")
          (prefer (family "JetBrainsMono Nerd Font")))))

    (simple-service 'my-env-vars
                    home-environment-variables-service-type
                    ;; XDG_DATA_HOME видимо выставляет кто-то другой. В консоли он есть.
                    ;; ИСПРАВЛЕНО: ru_RU.UTF-8 вместо utf8 для корректной работы Qt/GTK
                    '(("LANG"                . "ru_RU.UTF-8")
                      ("LC_ALL"              . "ru_RU.UTF-8")
                      ("LC_CTYPE"            . "ru_RU.UTF-8")
                      ("XDG_SESSION_TYPE"    . "wayland")
                      ("XDG_CURRENT_DESKTOP" . "wlroots")
                      ("MOZ_ENABLE_WAYLAND"  . "1")
                      ("QT_QPA_PLATFORM"     . "wayland")
                      ("SDL_VIDEODRIVER"     . "wayland")
                      ("EDITOR"              . "nvim")
                      ("VISUAL"              . "zed")))

    (service home-zsh-service-type
             (home-zsh-configuration
              (zshrc (list (local-file "zsh/zshrc")))
              (zshenv (list (local-file "zsh/zshenv")))
              (zprofile (list (local-file "zsh/zprofile")))
              (zlogin (list (local-file "zsh/zlogin")))))

    (service home-syncthing-service-type)
    ; (my-xray-service)
    )
   )
  )
