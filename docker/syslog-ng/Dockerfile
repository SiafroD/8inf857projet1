FROM balabit/syslog-ng:3.38

COPY syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

EXPOSE 514/udp 601/tcp

CMD ["syslog-ng", "--foreground", "--no-caps", "--cfgfile=/etc/syslog-ng/syslog-ng.conf"]

