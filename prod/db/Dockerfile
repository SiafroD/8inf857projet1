# The products and users database. Built (not the stock image) only so the log
# directory exists owned by postgres: an empty named volume mounted there then
# inherits that ownership, which the logging collector needs to write to it.
FROM docker.io/library/postgres:17.11-alpine

RUN mkdir -p /var/log/postgresql && chown postgres:postgres /var/log/postgresql
