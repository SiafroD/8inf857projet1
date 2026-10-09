# One small box with the client tools the scenarios need, so each script is just
# a few lines run from here: nothing offensive, only standard clients pointed at
# our own lab.
FROM docker.io/library/debian:trixie-slim
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl ca-certificates openssh-client sshpass nmap netcat-openbsd \
        postgresql-client python3 && \
    rm -rf /var/lib/apt/lists/*
