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
