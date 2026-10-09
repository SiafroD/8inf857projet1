#!/bin/bash

exec /usr/local/bin/docker-entrypoint.sh "$@" >> /usr/share/elasticsearch/logs/elasticsearch.log 2>&1