#!/usr/bin/env bash
set -euo pipefail

V8="/opt/1cv8/x86_64/8.3.27.1936"
DATA="/var/lib/1cv8"
LOGROOT="/var/log/1C"
LOGTECH="/var/log/1C/tech"

# 1C стандартно создаёт usr1cv8/grp1cv8, обычно uid=999 gid=1000
U="usr1cv8"
G="grp1cv8"

mkdir -p "$DATA" "$LOGTECH"

# Прод-минимум: гарантируем права на томах
chown -R "$U:$G" "$DATA" "$LOGROOT" || true
chmod 755 "$LOGROOT" "$LOGTECH" || true
chmod 775 "$DATA" || true

# Если техлог-конфиг примонтирован — кладём его туда, где 1С его ожидает
if [ -f /opt/1cv8/conf/logcfg.xml ]; then
  cp -f /opt/1cv8/conf/logcfg.xml "$DATA/logcfg.xml"
  chown "$U:$G" "$DATA/logcfg.xml" || true
  chmod 664 "$DATA/logcfg.xml" || true
fi

echo "=== Starting 1C (prod-minimum: ragent only) ==="
echo "Version   : 8.3.27.1936"
echo "Hostname  : $(hostname)"
echo "HostnameF : $(hostname -f 2>/dev/null || true)"
echo "Data dir  : $DATA"
echo "Log dir   : $LOGROOT"
echo "=============================================="

# Прод-минимум: PID1 = ragent (никаких ручных rmngr),
# rmngr/rphost поднимет сам ragent на основании srvinfo.
exec gosu "$U:$G" "$V8/ragent" \
  -d "$DATA" \
  -port 1540 \
  -regport 1541 \
  -range 1560:1591
