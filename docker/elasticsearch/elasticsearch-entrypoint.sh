#!/bin/bash

syslog-ng --no-caps --foreground --cfgfile=/etc/syslog-ng/syslog-ng.conf &
syslog_ng_pid=$!

/usr/local/bin/docker-entrypoint.sh "$@" &
elasticsearch_pid=$!

shutdown() {
    kill -TERM "$elasticsearch_pid" "$syslog_ng_pid" 2>/dev/null || true
}
trap shutdown TERM INT

status=0
wait -n "$syslog_ng_pid" "$elasticsearch_pid" || status=$?
shutdown
wait 2>/dev/null || true
exit "$status"