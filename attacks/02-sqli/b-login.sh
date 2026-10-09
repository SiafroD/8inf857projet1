#!/bin/sh
# 2b. SQL-injection attempt in the login username field. Same idea as 2a, on the
# other input the backend exposes.
. "$(dirname "$0")/../lib.sh"
echo "2b. Injection SQL sur le champ utilisateur du login"
on public sh -c '
curl -s -o /dev/null --data-urlencode "u=admin'"'"' OR '"'"'1'"'"'='"'"'1" --data "p=x" http://traefik-public/api/login
curl -s -o /dev/null --data-urlencode "u=admin'"'"';--" --data "p=x" http://traefik-public/api/login
'
