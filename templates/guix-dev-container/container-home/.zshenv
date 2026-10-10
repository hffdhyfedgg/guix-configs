# .zshenv — глобальные переменные окружения для контейнера
# Читается ВСЕГДА, даже для неинтерактивных shell

# SSL/TLS сертификаты (критично для curl, git, cargo)
export SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
export SSL_CERT_DIR="/etc/ssl/certs"
export GIT_SSL_CAINFO="$SSL_CERT_FILE"

# Пользовательские бинарники
export PATH="$HOME/.local/bin:$PATH"

# Локализация (если glibc-locales есть в манифесте)
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Предотвращаем чтение системных конфигов хоста (изоляция)
export ZDOTDIR="$HOME"
