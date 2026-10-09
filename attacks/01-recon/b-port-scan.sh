#!/bin/sh
# 1b. Port scan of the public zone: discover which services listen. TCP connect
# scan (-sT -Pn), so it needs no raw-socket privilege. Meant to trigger
# Suricata's scan rules (visible on the Docker target).
. "$(dirname "$0")/../lib.sh"
echo "1b. Scan de ports de la zone publique"
on public sh -c 'nmap -sT -Pn -T4 -p 1-1024,2222,3306,5432,8000 --open traefik-public nginx ssh'
