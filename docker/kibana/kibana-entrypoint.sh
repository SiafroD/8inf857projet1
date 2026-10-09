#!/bin/bash

syslog-ng --no-caps --foreground --cfgfile=/etc/syslog-ng/syslog-ng.conf &
syslog_ng_pid=$!

/usr/local/bin/kibana-docker "$@" &
kibana_pid=$!

shutdown() {
    kill -TERM "$kibana_pid" "$syslog_ng_pid" 2>/dev/null || true
}
trap shutdown TERM INT

status=0
wait -n "$syslog_ng_pid" "$kibana_pid" || status=$?
shutdown
wait 2>/dev/null || true
exit "$status"