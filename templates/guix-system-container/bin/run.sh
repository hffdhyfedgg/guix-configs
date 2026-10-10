#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Скрипт запуска, который собирает `guix system container`.
# Он обычно печатает:
#   system container is running as PID <pid>
#
# Важно: для корректной работы контейнера обычно нужен запуск от root.

if [[ ! -x ./result ]]; then
  echo "Container script not found. Run ./bin/build.sh first." >&2
  exit 1
fi

# Если вы хотите режим с общей сетью хоста, раскомментируйте
# и уберите настройку статической сети в os.scm:
#
# exec sudo ./result --network

# По умолчанию используем изолированный режим и потом поднимаем сеть
# вручную через ./bin/net-veth.sh.
exec sudo ./result
