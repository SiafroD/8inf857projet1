#!/bin/sh
# 2a. SQL-injection attempt on the product search. The backend uses parameterised
# queries, so this is logged, not executed: it shows in the backend log and in
# Suricata's SQL-injection rule.
. "$(dirname "$0")/../lib.sh"
echo "2a. Injection SQL sur la recherche"
on public sh -c '
curl -s -o /dev/null -G "http://traefik-public/api/search" --data-urlencode "q=1 UNION SELECT username,pw_hash FROM users"
curl -s -o /dev/null -G "http://traefik-public/api/search" --data-urlencode "q=perceuse'"'"' OR '"'"'1'"'"'='"'"'1"
'
