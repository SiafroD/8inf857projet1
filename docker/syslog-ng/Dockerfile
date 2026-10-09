FROM balabit/syslog-ng:4.11.0

RUN apt-get update && \
	apt-get install -y --no-install-recommends syslog-ng-mod-http && \
	rm -rf /var/lib/apt/lists/*

COPY syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

EXPOSE 514/udp 601/tcp


