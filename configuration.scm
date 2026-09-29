;; (primitive-load "/run/nonguix-channel/nongnu/packages/linux.scm")

(use-modules (gnu)
             (gnu system locale)
             ; (gnu packages linux)
			 ; (gnu packages disk)
			 (gnu services sysctl)
			; (gnu packages shells)
             (nongnu packages linux)
             (nongnu system linux-initrd)
             (guix gexp)
             (srfi srfi-1)
            ; (gnu packages lxqt)
                )

    ;; gnome только для удаления в конце
(use-service-modules desktop networking ssh xorg admin)
;; Подключаем модули с пакетами
(use-package-modules linux xorg image freedesktop disk lxqt shells terminals vim fonts xdisorg window-management admin networking)
;; Я не понимаю нужен ли тут wm или window-managment! guix жалуется что нужен window-management, а в установочном образе что нужен wm! ИИ говорит что нужен wm! Я ничего не понимаю.

(operating-system
  (host-name "hp-guix-lab080")
  (timezone "Europe/Moscow")
  (locale "ru_RU.UTF-8")
  (locale-definitions
    (list (locale-definition (name "ru_RU.UTF-8")
                             (source "ru_RU.UTF-8"))
          (locale-definition (name "en_US.UTF-8")
                             (source "en_US.UTF-8"))))
  (keyboard-layout (keyboard-layout "us,ru"
                                    #:options '("grp:alt_shift_toggle")))
                                    ;; или "grp:win_space_toggle" для переключения по Win+Space

  ;; Несвободное ядро для работы Wi-Fi и видеокарт
  (kernel linux)
  (initrd microcode-initrd)
  (firmware (list linux-firmware))

  (kernel-arguments
    (append
		(list
		  "zswap.enabled=1"
		  "zswap.compressor=lz4"
		  "zswap.max_pool_percent=15"
		  "zswap.accept_threshold_percent=85"
		  "zswap.shrinker_enabled=1"
		  "zswap.exclusive_loads=1"
		)
	 ;; Обязательно сохраняем дефолтные аргументы ядра!
     %default-kernel-arguments
	)
  )



  ;; --- Загрузчик  ---
  ;; Монтируем корневой раздел (замените UUID на ваш)
  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (targets '("/dev/sda"))   ; <-- замените sdX на sda
				(menu-entries         ; <-- добавляем записи для Windows
				 (list
				  (menu-entry
					(label "Windows (7/XP)")
					(device (file-system-label "WinXP"))   ; получите через blkid /dev/sda2
					(chain-loader "+1"))
				  ))
                ))

  ;; --- Файловые системы ---
  (file-systems (cons* (file-system
                          (device (file-system-label "guix-root"))
                          (mount-point "/")
                          (type "btrfs"))

                        %base-file-systems))

    ;; --- Swap-file ---
    (swap-devices
    (list (swap-space
        (target "/swap/swapfile"))))
    ;; ПОЛЬЗОВАТЕЛИ
    (users (cons (user-account
                (name "pv") ; Замените на своё имя
                (comment "PV")
                (group "users")
                (home-directory "/home/pv")
                ;; netdev нужен для работы с NetworkManager без root-прав, wheel для sudo
                (supplementary-groups '("wheel" "netdev" "audio" "video" "input"))
                (shell (file-append zsh "/bin/zsh"))) ;; <--- ВОТ ЭТО ГЛАВНОЕ
            %base-user-accounts))


  ;; ПАКЕТЫ (Используем specification->package, чтобы не мучиться с модулями)
  (packages
   (append
    (list
        ;; WM и окружение — модуль (gnu packages wm), не window-management
        sway
        lxqt
        ; labwc
        ; waybar
        ; wlr-randr

        xorg-server-xwayland
        xdg-desktop-portal
        xdg-desktop-portal-wlr
        alacritty
        neovim
        wl-clipboard
        grim
        slurp

        ;; Шрифты
        font-dejavu
        font-liberation
        font-fira-code
        font-google-noto

        zsh

        ;; Сеть
        yggdrasil


        ;; PRIME offload: запуск приложений на GPU через prime-run <cmd>
        ; nvidia-prime        ;; --- ПАКЕТЫ ДЛЯ GTK-ОКРУЖЕНИЯ ---
        ; Ещё подумаю, нужно ли это
        ; adwaita-icon-theme       ;; Стандартные иконки GNOME (Adwaita)
        ; dconf                    ;; Бэкенд для хранения настроек GTK/GNOME
        ; gsettings-desktop-schemas ;; Схемы настроек для gsettings
        ; nwg-look                 ;; GUI-утилита для выбора GTK-тем и иконок в Wayland
        gparted)
    %base-packages))

  (services
   (append
    (list



     (service openssh-service-type)

     (service yggdrasil-service-type
         (yggdrasil-configuration
             (config-file (local-file "/etc/yggdrasil.conf"))))

     (service greetd-service-type
              (greetd-configuration
               (terminals
                (list
                 (greetd-terminal-configuration
                  (terminal-vt "1")
                  (terminal-switch #t)
                  (default-session-command
                   #~(string-append
                      #$cage "/bin/cage"
                      " -s -- "
                      #$gtkgreet "/bin/gtkgreet"))))))))

	  (remove (lambda (service)
			  (and (eq? (service-kind service) mingetty-service-type)
				   (string=? (mingetty-configuration-tty
							  (service-value service))
							 "tty1")))
			(modify-services %desktop-services
			  (delete gdm-service-type)
			  (sysctl-service-type config =>
				(sysctl-configuration

				  (settings (append '(("vm.swappiness" . "60"))
									%default-sysctl-settings))))
			  )
	  )
   ))
)
