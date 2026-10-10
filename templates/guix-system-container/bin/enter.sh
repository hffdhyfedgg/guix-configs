#!/usr/bin/env bash
set -euo pipefail

# Вход в системный контейнер без SSH.
#
# Требуется:
# - знать PID контейнера
# - иметь права на выполнение `nsenter`
#
# Использование:
#   ./bin/enter.sh <pid>
#   ./bin/enter.sh <pid> /bin/bash

if [[ $# -lt 1 ]]; then
  cat <<EOF
Usage: $0 <container-pid> [command]

Example:
  $0 5983
  $0 5983 /bin/bash
