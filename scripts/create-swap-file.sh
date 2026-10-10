#!/usr/bin/env -S bash
# create-swapfile.sh
# Создаёт swap-файл на Btrfs в отдельном подтоме.
# Использование: sudo bash create-swapfile.sh [размер, например 4G]

set -euo pipefail

SWAP_SIZE="${1:-4G}"
SWAP_SUBVOL="/swap"
SWAP_FILE="${SWAP_SUBVOL}/swapfile"

# --- Проверки ---

if [[ $EUID -ne 0 ]]; then
    echo "Ошибка: скрипт нужно запускать от root (sudo)." >&2
    exit 1
fi

if [[ -e "$SWAP_FILE" ]]; then
    echo "⚠️  Предупреждение: файл ${SWAP_FILE} уже существует!"
    echo "   Если вы хотите пересоздать его (изменить размер):"
    echo "   1. sudo swapoff ${SWAP_FILE}"
    echo "   2. sudo rm ${SWAP_FILE}"
    echo "   3. Запустите скрипт снова."
    exit 1
fi

# --- Создание подтома (если ещё нет) ---

if ! btrfs subvolume show "$SWAP_SUBVOL" &>/dev/null; then
    echo "→ Создаём подтом ${SWAP_SUBVOL}..."
    btrfs subvolume create "$SWAP_SUBVOL"
    chmod 700 "$SWAP_SUBVOL"
else
    echo "→ Подтом ${SWAP_SUBVOL} уже существует, пропускаем."
fi

# --- Создание swap-файла ---
# btrfs filesystem mkswapfile сама делает:
#   - fallocate (преаллокация без дыр)
#   - chattr +C (NODATACOW — обязательно для Btrfs!)
#   - mkswap (запись сигнатуры подкачки)

echo "→ Создаём swap-файл ${SWAP_FILE} размером ${SWAP_SIZE}..."
btrfs filesystem mkswapfile --size "$SWAP_SIZE" "$SWAP_FILE"

echo ""
echo "Swap-файл создан: ${SWAP_FILE}"
