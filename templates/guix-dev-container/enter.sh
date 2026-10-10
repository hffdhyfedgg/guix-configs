#!/usr/bin/env zsh
set -euo pipefail

cd "$(dirname "$0")"

HOST_HOME="$PWD/container-home"
HOST_PROJECT="$PWD/src"

exec guix shell --container --emulate-fhs --network \
  --preserve='^USER$|^TERM$|^COLORTERM$|^DISPLAY$' \
  --share="$HOST_HOME=/home/user" \
  --share="$HOST_PROJECT=/src" \
  --manifest="$HOST_PROJECT/manifest.scm" \
  -- sh -c '
    export HOME=/home/user
    cd /src 2>/dev/null

    # Обязательный exec: либо команда из аргументов, либо zsh
    if [ "$#" -gt 0 ]; then
      exec "$@"
    else
      exec zsh
    fi
  ' _ "$@"
