#!/bin/sh
set -e
# Host keys are regenerated on each start: fine for a throwaway lab box (a client
# just re-trusts it). sshd -e writes its log to stderr; we append it to the shared
# volume the agent reads, since sshd cannot forward to a remote syslog itself.
ssh-keygen -A
mkdir -p /var/log/sshd
exec /usr/sbin/sshd -D -e 2>>/var/log/sshd/auth.log
