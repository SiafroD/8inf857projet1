#!/bin/sh
set -e
# Host keys are regenerated on each start: fine for a throwaway lab box (a client
# just re-trusts it). sshd -e writes its log to stderr; we append it to the shared
# volume the agent reads, since sshd cannot forward to a remote syslog itself.
ssh-keygen -A
mkdir -p /var/log/sshd
# sshd and the Wazuh agent (FIM) share this container: start the agent's daemons in
# the background (they auto-enroll against the manager), then hand PID 1 to sshd.
/var/ossec/bin/wazuh-control start
exec /usr/sbin/sshd -D -e 2>>/var/log/sshd/auth.log
