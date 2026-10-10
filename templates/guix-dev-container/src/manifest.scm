;;; manifest.scm — базовое окружение разработки

(concatenate-manifests
 (list
  ;; Базовые утилиты (замените на ваш base.scm при необходимости)
  (specifications->manifest
   '("coreutils" "grep" "sed" "findutils" "which" "file"))

  ;; Специфичные зависимости
  (specifications->manifest
   '("zsh"              ; оболочка
     "libcap"           ; capsh для управления capabilities
     "nss-certs"        ; SSL-сертификаты
     "glibc-locales"    ; Локализация UTF-8
     "git"              ; VCS
     "curl"             ; HTTP-клиент
     "tar" "gzip" "xz"  ; Архиваторы
     "python"           ; Скрипты
     ))))
