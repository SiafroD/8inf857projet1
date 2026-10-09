# A plain Linux host exposed on the public zone. It runs nothing but sshd, so
# the lab has an SSH login to attack; its only job is to produce auth logs.
FROM docker.io/library/debian:trixie-slim

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openssh-server && \
    rm -rf /var/lib/apt/lists/*

# sysadmin / azerty123: a weak password on purpose, so the brute-force scenario
# has a target. Password login is on for the same reason.
RUN useradd -m -s /bin/bash sysadmin && \
    echo 'sysadmin:azerty123' | chpasswd

COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

EXPOSE 22
ENTRYPOINT ["/usr/local/bin/entrypoint"]
