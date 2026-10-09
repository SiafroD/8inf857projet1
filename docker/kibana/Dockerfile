FROM docker.elastic.co/kibana/kibana:9.0.2

USER root

RUN apt-get update && apt-get install -y syslog-ng syslog-ng-core && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

COPY kibana.yml /usr/share/kibana/config/kibana.yml
COPY syslog-ng.conf /etc/syslog-ng/syslog-ng.conf
COPY kibana-entrypoint.sh /usr/local/bin/kibana-entrypoint

RUN chmod 0755 /usr/local/bin/kibana-entrypoint && \
	mkdir -p /usr/share/kibana/logs /var/lib/syslog-ng /var/run/syslog-ng && \
	chown -R kibana:root /usr/share/kibana/logs /var/lib/syslog-ng /var/run/syslog-ng

USER kibana

ENTRYPOINT ["/usr/local/bin/kibana-entrypoint"]