#!/bin/sh
# 1a. Web reconnaissance: ask for files that should never be served, with the
# user agents of common scanners. Meant to trigger Suricata's scanner and
# sensitive-path rules, and to fill nginx's log with 404s.
. "$(dirname "$0")/../lib.sh"
echo "1a. Reconnaissance web (scanner de fichiers sensibles)"
on public sh -c '
for p in /.git/config /.env /wp-login.php /phpmyadmin/ /server-status /backup.zip; do
    curl -s -o /dev/null -A "Nikto/2.5.0" "http://traefik-public$p"
done
curl -s -o /dev/null -A "sqlmap/1.8" "http://traefik-public/"
'
