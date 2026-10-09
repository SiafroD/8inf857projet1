FROM balabit/syslog-ng:4.12.0

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		-o Dpkg::Options::="--force-confdef" \
		-o Dpkg::Options::="--force-confold" \
		syslog-ng-mod-http && \
	rm -rf /var/lib/apt/lists/*

COPY syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

EXPOSE 514/udp 601/tcp 602/tcp


