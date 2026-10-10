# A plain Linux host exposed on the public zone. It runs sshd, so the lab has an SSH
# login to attack, plus a Wazuh agent whose FIM watches the files the persistence
# scenario tampers with (authorized_keys, .bashrc).
FROM docker.io/library/debian:trixie-slim

# openssh-server for the attack surface; the Wazuh apt repo for the agent, pinned to
# the manager's version (4.14.8).
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openssh-server ca-certificates curl gnupg && \
    curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | \
        gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && \
    chmod 644 /usr/share/keyrings/wazuh.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" \
        > /etc/apt/sources.list.d/wazuh.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y wazuh-agent=4.14.8-1 && \
    rm -rf /var/lib/apt/lists/*

# sysadmin / azerty123: a weak password on purpose, so the brute-force scenario
# has a target. Password login is on for the same reason.
RUN useradd -m -s /bin/bash sysadmin && \
    echo 'sysadmin:azerty123' | chpasswd

COPY sshd_config /etc/ssh/sshd_config
COPY ossec.conf /var/ossec/etc/ossec.conf
COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

EXPOSE 22
ENTRYPOINT ["/usr/local/bin/entrypoint"]
