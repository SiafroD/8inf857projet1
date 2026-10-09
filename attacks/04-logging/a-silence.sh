#!/bin/sh
# 4a. A compromised host cuts its telemetry: we stop one log agent, so its source
# goes silent. Detection is about noticing the gap (no new logs from that source).
# Restart it with:  docker compose up -d <name>
. "$(dirname "$0")/../lib.sh"
TARGET=${1:-ssh-log-agent}
echo "4a. Coupure de la telemetrie: arret de $TARGET"
"$RT" stop "${PROJ}-${TARGET}-1" 2>/dev/null || "$RT" stop "$TARGET" 2>/dev/null
echo "Source silencieuse. Relancer: $RT start ${PROJ}-${TARGET}-1"
