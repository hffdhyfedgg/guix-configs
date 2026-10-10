;;; os.scm — Guix System Container
;;;
;;; Это полноценная декларация операционной системы, которая будет запущена
;;; как контейнер. Здесь можно объявлять сервисы, пользователей, правила
;;; межсетевого экрана, статическую сеть и т.д.
;;;
;;; Запуск:
;;;   ./bin/build.sh
;;;   sudo ./bin/run.sh

(use-modules
 (gnu)
 (gnu services)
 (gnu services base)
 (gnu services networking)
 (gnu services ssh)
 (gnu services admin)              ; для unattended-upgrade, если понадобится
 (gnu services databases)          ; например для postgres
 (gnu services web)                ; например для nginx
 (gnu services shepherd)
 (gnu system)
 (gnu system file-systems)
 (gnu system shadow)
 (gnu packages)
 (gnu packages ssh)
 (gnu packages admin)
 (gnu packages databases)
 (gnu packages web)
 (guix gexp)
 (ice-9 match))

(use-service-modules desktop)       ; часто удобно иметь базовые сервисы

;;; ------------------------------------------------------------
;;; Сетевой режим
;;; ------------------------------------------------------------
;;;
;;; 1) shared  — контейнер использует сетевой стек хоста.
;;;    Запуск: guix system container --network os.scm
;;;    Подходит для разработки и когда изоляция сети не нужна.
;;;
;;; 2) veth    — контейнер без сети хоста; сеть настраивается вручную
;;;    через veth-пару после запуска. Подходит для жёсткой политики:
;;;    «весь трафик только через шлюз/прокси».
;;;
;;; 3) изолированный без сети — контейнер вообще не имеет сети.
;;;
;;; Ниже по умолчанию настроен режим veth с единственным маршрутом
;;; через шлюз 10.0.0.1, где на хосте должен работать прокси/шлюз.

(define %network-mode 'veth)   ;; 'shared | 'veth | 'isolated

;;; ------------------------------------------------------------
;;; Пользователи
;;; ------------------------------------------------------------

(define %users
  (list
   (user-account
     (name "dev")
     (comment "Container developer")
     (group "users")
     (home-directory "/home/dev")
     (supplementary-groups '("wheel" ; sudo, если включить
                             "netdev")))))

;;; ------------------------------------------------------------
;;; Статическая сеть для режима veth
;;; ------------------------------------------------------------
;;;
;;; Важно: контейнер стартует без сети, если не использовать
;;; --network. Мы описываем интерфейс, который потом появится внутри
;;; контейнера после настройки на хосте через `ip netns`.

(define %container-interface "eth0")
(define %container-address "10.0.0.2/24")
(define %gateway-address "10.0.0.1")

(define %static-network
  (static-networking
   (interface %container-interface)
   (addresses
    (list
     (network-address
      (device %container-interface)
      (value %container-address))))
   (routes
    (list
     ;; Единственный маршрут по умолчанию.
     ;; Это значит, что контейнер может отправлять трафик только через
     ;; 10.0.0.1. Если на хосте/шлюзе поднять прокси или сделать
     ;; прозрачный NAT в VPN, то весь трафик пойдёт туда.
     (network-route
      (destination "default")
      (gateway %gateway-address))))
   ;; Для разработки можно указать внутренний DNS хоста.
   (name-servers '("10.0.0.1"))))

;;; ------------------------------------------------------------
;;; Nftables
;;; ------------------------------------------------------------
;;;
;;; В системном контейнере это работает так же, как в обычной системе,
;;; но требует соответствующих возможностей ядра и прав. При запуске
;;; контейнера из-под root обычно нормально.

(define %nftables-ruleset
  ;; Если файл один — можно просто:
  ;; (local-file "config/nftables/default.nft")
  ;;
  ;; Для режима полного проксирования можно ограничить исходящие порты:
  ;; разрешить только прокси/VPN, остальное дропать.
  ;;
  ;; Пример ниже — умеренный: разрешаем установленные и локальные,
  ;; в конце можно поставить policy drop.
  (local-file "config/nftables/default.nft"))

;;; ------------------------------------------------------------
;;; Сервисы
;;; ------------------------------------------------------------

(define %base-services
  (list
   ;; Минимальный набор.
   (service sysctl-service-type)

   ;; Логи.
   (service system-log-service-type)

   ;; Если нужен SSH внутри контейнера.
   ;; В контейнере можно без него, если используете `nsenter`.
   ;; Но иногда удобно иметь запасной вход.
   ;;
   ;; (service openssh-service-type
   ;;   (openssh-configuration
   ;;    (port-number 2222)
   ;;    (permit-root-login #f)
   ;;    (password-authentication? #f)
   ;;    (authorized-keys
   ;;     `(("dev" ,(local-file "config/ssh/example-authorized-keys"))))))

   ;; Межсетевой экран.
   (service nftables-service-type
     (nftables-configuration
      (ruleset %nftables-ruleset)))

   ;; Статическая сеть для режима veth.
   ;; Для режима 'shared обычно не нужно.
   (service static-networking-service-type
     (list %static-network))

   ;; Пример: cron/mcron, если нужно.
   ;; (service mcron-service-type
   ;;   (mcron-configuration
   ;;    (jobs (list #~(job '(next-minute '(0))
   ;;                       (lambda ()
   ;;                         (system "logger hello from cron")))))))
   ))

;;; ------------------------------------------------------------
;;; Пример: простой собственный сервис
;;; ------------------------------------------------------------

;; Это минимальный пример: сервис просто держит процесс, который пишет
;; лог в файл. Для реального приложения замените команду и добавьте
;; зависимости, окружение, рабочие каталоги.

(define %example-app-service
  (service
   (shepherd-service
    (documentation "Example long-running application")
    (provision '(example-app))
    (requirement '(networking))
    (start #~(make-forkexec-constructor
              (list #$(file-append coreutils "/bin/sh")
                    "-c"
                    "while true; do echo hello >> /var/log/example-app.log; sleep 5; done")
              #:log-file "/var/log/example-app.log"))
    (stop #~(make-kill-destructor)))))

;;; ------------------------------------------------------------
;;; Пример: nginx
;;; ------------------------------------------------------------

(define %nginx-service
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

;;; ------------------------------------------------------------
;;; Пример: PostgreSQL
;;; ------------------------------------------------------------

;; (define %postgres-service
;;   (service postgresql-service-type
;;     (postgresql-configuration
;;      (postgresql postgresql-14)
;;      (config-file
;;       (postgresql-config-file
;;        (log-destination "stderr")
;;        (hba-file
;;         (plain-file "pg_hba.conf"
;;           "\
;; local all all trust
;; host  all all 10.0.0.0/24 trust"))
;;        (extra-config
;;         '(("listen_addresses" "*")
;;           ("log_directory" "/var/log/postgresql"))))))))

;;; ------------------------------------------------------------
;;; Операционная система
;;; ------------------------------------------------------------

(operating-system
  (host-name "guix-sc")
  (timezone "UTC")
  (locale "en_US.utf8")

  ;; Для контейнера файловая система "не важна".
  ;; Это требование декларативного интерфейса.
  (file-systems
   (cons
    (file-system
      (device (file-system-label "does-not-matter"))
      (mount-point "/")
      (type "ext4"))
    %base-file-systems))

  ;; Bootloader для контейнера не используется, но поле обязательно.
  (bootloader
   (bootloader-configuration
    (bootloader grub-bootloader)
    (targets '("/dev/sdX"))))

  ;; Пользователи.
  (users %users)

  ;; Дополнительные пакеты, доступные внутри контейнера.
  (packages
   (append
    (list
     coreutils
     grep
     sed
     which
     iproute
     curl
     nss-certs
     glibc-locales
     ;; Если используете вход по nsenter и хотите нормальный шелл:
     bash
     ;; Для диагностики сети:
     iputils
     ;; Для отладки:
     strace
     ;; Добавьте нужные инструменты:
     ;; postgresql
     ;; nginx
     )
    %base-packages))

  ;; Сервисы.
  (services
   (append
    (list
     %example-app-service
     ;; %nginx-service
     ;; %postgres-service
     )
    %base-services)))
