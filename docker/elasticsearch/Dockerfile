# syntax=docker/dockerfile:1
FROM docker.elastic.co/elasticsearch/elasticsearch:9.0.2

# install syslog-ng
RUN apt-get update && apt-get install -y syslog-ng syslog-ng-core syslog-ng-mod-sql syslog-ng-mod-json syslog-ng-mod-smtp && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY syslog-ng.conf /etc/syslog-ng/syslog-ng.conf
COPY elasticsearch-entrypoint.sh /usr/local/bin/elasticsearch-entrypoint

RUN chmod 0755 /usr/local/bin/elasticsearch-entrypoint && \
    mkdir -p /var/lib/syslog-ng /var/run/syslog-ng && \
    chown -R elasticsearch:root /var/lib/syslog-ng /var/run/syslog-ng

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/elasticsearch-entrypoint"]
CMD ["eswrapper"]

