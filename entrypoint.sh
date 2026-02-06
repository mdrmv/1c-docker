#!/usr/bin/env bash
set -euo pipefail

V8="/opt/1cv8/x86_64/8.3.27.1936"
DATA="/var/lib/1cv8"
LOGDIR="/var/log/1C/tech"

mkdir -p "$DATA" /var/log/1C/tech
chmod 755 /var/log/1C /var/log/1C/tech || true

echo "=== Starting 1C (bridge+ports baseline) ==="
echo "Version  : 8.3.27.1936"
echo "Data dir : $DATA"
echo "=========================================="

# Запускаем ragent в фоне
"$V8/ragent" -d "$DATA" -port 1540 -regport 1541 -range 1560:1591 &
RAGENT_PID=$!

# Дадим ragent подняться
sleep 1

# Запускаем rmngr в фоне (в bridge имя хоста контейнера допустимо)
HOSTNAME_FQ="$(hostname)"
"$V8/rmngr" -port 1541 -host "$HOSTNAME_FQ" -range 1560:1591 -d "$DATA" &
RMNGR_PID=$!

# Покажем сокеты
echo "--- ss ---"
ss -lntp | egrep ':(1540|1541|1560)\b' || true

# Живём пока живы процессы
wait "$RAGENT_PID" "$RMNGR_PID"
