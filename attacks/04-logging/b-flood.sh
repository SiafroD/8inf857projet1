#!/bin/sh
# 4b. Log flooding: a compromised source on the logs network sends a burst of
# syslog lines to drown the real events. Capped so the lab survives; detection is
# about spotting the volume spike. COUNT overridable: ./b-flood.sh 20000
. "$(dirname "$0")/../lib.sh"
COUNT=${1:-5000}
echo "4b. Saturation des logs: $COUNT lignes vers syslog-ng"
on logs sh -c '
i=0
while [ $i -lt '"$COUNT"' ]; do
    printf "<134>flood: noise line %d padding padding padding padding\n" $i
    i=$((i+1))
done | nc -u -w2 syslog-ng 514
'
echo "Envoye."
