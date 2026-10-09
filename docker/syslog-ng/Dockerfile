FROM balabit/syslog-ng:3.38.1

COPY syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

EXPOSE 514/udp 601/tcp

ENTRYPOINT ["syslog-ng"]
CMD ["-F", "--no-caps"]

