;; vm.scm — минимальная система Guix для QEMU
(use-modules
    (gnu)
    (gnu system locale)
    )

(use-service-modules networking ssh)
(use-package-modules shells vim)

(operating-system
  (host-name "guix-vm")
  (timezone "Europe/Moscow")
  (locale "ru_RU.utf8")
  ; (locale-definitions
  ;  (list (locale-definition (name "ru_RU.UTF8") (source "ru_RU.UTF8"))
  ;        (locale-definition (name "en_US.UTF8") (source "en_US.UTF8"))))
  (keyboard-layout (keyboard-layout "us,ru"
                                    #:options '("grp:alt_shift_toggle")))

  ;; Загрузчик. Для `guix system vm` и `guix system image` эти поля
  ;; фактически игнорируются/переопределяются (Guix сам ставит GRUB
  ;; в образ и сама грузит ядро), но они обязательны синтаксически и
  ;; пригодятся, если будете делать `guix system init` на пустой
  ;; виртуальный диск.
  (bootloader (bootloader-configuration
               (bootloader grub-bootloader)
               (targets '("/dev/sda"))
               (terminal-outputs '(console))))

  (file-systems (cons (file-system
                       (device (file-system-label "guix-vm-root"))
                       (mount-point "/")
                       (type "ext4"))
                      %base-file-systems))

  ;; Пользователь: wheel для sudo, zsh как раньше.
  ;; Группы netdev/audio/video/input не нужны: ни NetworkManager,
  ;; ни звука/графики в головной ВМ нет.
  (users (cons (user-account
                (name "pv")
                (comment "PV")
                (group "users")
                (supplementary-groups '("wheel"))
                (home-directory "/home/pv")
                (shell (file-append zsh "/bin/zsh")))
               %base-user-accounts))

  (packages (cons* zsh neovim %base-packages))

  (services
   (cons*
       (service static-networking-service-type
                (list (static-networking
                       (addresses (list (network-address
                                         (device "enp0s3")   ; уточните через `ip link` в ВМ
                                         (value "10.0.2.15/24"))))
                       (routes (list (network-route
                                      (destination "default")
                                      (gateway "10.0.2.2"))))
                       (name-servers '("10.0.2.3")))))

    ;; SSH — оставили как в исходном конфиге (порт 22, настройки по умолчанию)
    (service openssh-service-type)

    %base-services)))
