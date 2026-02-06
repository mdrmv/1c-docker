#!/usr/bin/env bash
set -euo pipefail

V8="/opt/1cv8/x86_64/8.3.27.1936"
DATA="/var/lib/1cv8"

mkdir -p "$DATA" /var/log/1C/tech
chmod 755 /var/log/1C /var/log/1C/tech || true

echo "=== Starting 1C (canonical: ragent only) ==="
echo "Version   : 8.3.27.1936"
echo "Hostname  : $(hostname)"
echo "HostnameF : $(hostname -f || true)"
echo "Data dir  : $DATA"
echo "==========================================="

# Канонично: запускаем только ragent.
# rmngr/rphost должны подниматься автоматически ragent'ом по состоянию кластера (srvinfo).
exec su -s /bin/bash usr1cv8 -c \
  "exec \"$V8/ragent\" -d \"$DATA\" -port 1540 -regport 1541 -range 1560:1591"
