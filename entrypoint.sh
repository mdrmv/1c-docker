#!/usr/bin/env bash
set -euo pipefail

VER="8.3.27.1936"
BIN="/opt/1cv8/x86_64/${VER}"

RAGENT="${BIN}/ragent"
RMNGR="${BIN}/rmngr"

DATA_DIR="/var/lib/1cv8"
LOG_DIR="/var/log/1C"

PORT_AGENT=1540
PORT_RMNGR=1541
RANGE="1560:1591"

# IP контейнера (для справки/диагностики)
HOST_IP="$(ip route get 1 | awk '{print $7; exit}')"

# Главное: имя, которое rmngr "отдаёт" клиентам.
# 1) если задано HOST_FQDN (из compose) — используем его
# 2) иначе пытаемся взять FQDN через hostname -f
# 3) иначе собираем из hostname + domainname
# 4) иначе падаем на IP (как аварийный вариант)
HOST_FQDN="${HOST_FQDN:-}"
if [ -z "${HOST_FQDN}" ]; then
  HOST_FQDN="$(hostname -f 2>/dev/null || true)"
fi
if [ -z "${HOST_FQDN}" ]; then
  HN="$(hostname 2>/dev/null || true)"
  DN="$(cat /etc/resolv.conf 2>/dev/null | awk '/^search/{print $2; exit}' || true)"
  if [ -n "${HN}" ] && [ -n "${DN}" ]; then
    HOST_FQDN="${HN}.${DN}"
  else
    HOST_FQDN="${HN:-${HOST_IP}}"
  fi
fi

echo "=== Starting 1C:Enterprise (canonical bridge+ports) ==="
echo "Version    : ${VER}"
echo "Host IP    : ${HOST_IP}"
echo "Host FQDN  : ${HOST_FQDN}"
echo "ragent     : ${PORT_AGENT}"
echo "rmngr      : ${PORT_RMNGR}"
echo "range      : ${RANGE}"
echo "Data dir   : ${DATA_DIR}"
echo "Log dir    : ${LOG_DIR}"
echo "======================================================"

mkdir -p "${DATA_DIR}" "${LOG_DIR}"

# права для данных (usr1cv8 обычно uid=999, grp1cv8 gid=1000)
chown -R 999:1000 "${DATA_DIR}" "${LOG_DIR}" || true
chmod -R 775 "${DATA_DIR}" "${LOG_DIR}" || true

# применяем техлог, если есть
if [ -f /opt/1cv8/conf/logcfg.xml ]; then
  echo "Applying tech log config"
  cp -f /opt/1cv8/conf/logcfg.xml "${DATA_DIR}/logcfg.xml"
  chown 999:1000 "${DATA_DIR}/logcfg.xml" || true
  chmod 664 "${DATA_DIR}/logcfg.xml" || true
fi

echo "--- ss before start ---"
ss -lntp | egrep ':(1540|1541|1560)\b' || true

# 1) ragent — в фоне
"${RAGENT}" \
  -d "${DATA_DIR}" \
  -port "${PORT_AGENT}" \
  -regport "${PORT_RMNGR}" \
  -range "${RANGE}" &

sleep 2

echo "--- ss after ragent ---"
ss -lntp | egrep ':(1540|1541|1560)\b' || true

# 2) rmngr — основной процесс (PID 1)
exec "${RMNGR}" \
  -port "${PORT_RMNGR}" \
  -host "${HOST_FQDN}" \
  -range "${RANGE}" \
  -d "${DATA_DIR}"
