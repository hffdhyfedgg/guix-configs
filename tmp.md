# Структура файлов проекта

## Дерево проекта

```
guix-container/
├── app/
│   └── manifest.scm
├── container-home/
│   └── setup.sh
└── enter.sh
```

---

## Директория: `guix-container`

Найдено 1 файл(ов):

### Файл: `enter.sh`

```
#!/usr/bin/env zsh
set -euo pipefail

cd "$(dirname "$0")"

HOST_HOME="$PWD/container-home"
HOST_PROJECT="$PWD/app"

exec guix shell --container --emulate-fhs --network \
  --preserve='^USER$|^TERM$|^COLORTERM$|^DISPLAY$' \
  --share="$HOST_HOME=/home/user" \
  --share="$HOST_PROJECT=/app" \
  --manifest="$HOST_PROJECT/manifest.scm" \
  -- sh -c '
    export HOME=/home/user
    cd /app 2>/dev/null

    # Обязательный exec: либо команда из аргументов, либо zsh
    if [ "$#" -gt 0 ]; then
      exec "$@"
    else
      exec zsh
    fi
  ' _ "$@"

```

---

### Директория: `app`

Найдено 1 файл(ов):

#### Файл: `manifest.scm`

```
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

```

---

### Директория: `container-home`

Найдено 1 файл(ов):

#### Файл: `setup.sh`

```
#!/bin/sh
# setup.sh — выполняется внутри контейнера перед запуском оболочки
# Принцип: только то, что нельзя версионить в container-home/

set -eu

# Гарантируем наличие динамических директорий (на случай, если .gitignore их чистит)
mkdir -p "$HOME/.local/bin" \
         "$HOME/.local/share" \
         "$HOME/.cache" \
         "$HOME/.config"

# Если нужны специфичные для проекта действия (например, генерация токенов),
# добавьте их здесь. Но не перегружайте — всё постоянное должно быть в .zshenv.

# Пример: проверка наличия критичных бинарников
command -v zsh >/dev/null 2>&1 || { echo "Ошибка: zsh не найден в манифесте"; exit 1; }

```

---

