#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

exec guix system container \
  --root=./result \
  os.scm
