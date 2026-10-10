# Installation pas-à-pas

## Prérequis

- **Docker** (avec le plugin Compose) **ou Podman** (`podman compose`). Les images
  sont toutes qualifiées `docker.io/...` et le `docker-compose.yml` est standard,
  donc les deux marchent. *Podman est moins testé par l'équipe : voir les pièges
  en bas.*
- **~6 Go de RAM libres.** Elasticsearch (~2 Go), puis Kibana, Wazuh et Suricata
  (~0,5 Go chacun). Sous Docker Desktop (Windows/macOS), augmenter la RAM allouée
  à la VM, sinon des conteneurs sont tués (code `137`).
- **`vm.max_map_count` ≥ 262144** (exigé par Elasticsearch) :
  ```sh
  sudo sysctl -w vm.max_map_count=262144
  ```

## Lancer toute la pile

Depuis la racine du dépôt :

```sh
docker compose up -d --build      # ou : podman compose up -d --build
```

La première fois, le build de Suricata (jeu de règles ET Open) et le
téléchargement des images Elastic prennent quelques minutes. Les services d'init
(`wazuh-template`, `kibana-setup`) tournent une fois puis s'arrêtent avec le code
`0` — c'est normal.

Vérifier que tout est debout :

```sh
docker compose ps        # tout en "Up"/"healthy", sauf les 2 services d'init en "Exited (0)"
```

## Les briques, une par une

Rien à installer à la main : chaque composant est un conteneur. Voici comment
**vérifier** que chacun fonctionne.

### 1. Elasticsearch (base)

```sh
docker exec elasticsearch curl -s localhost:9200/_cluster/health
# attendu : "status":"green" ou "yellow"
docker exec elasticsearch curl -s 'localhost:9200/_cat/indices/syslog-*,wazuh-*?v'
# attendu : les index syslog-2026.MM et wazuh-alerts-4.x-AAAA.MM.JJ apparaissent
```

### 2. syslog-ng (collecte)

Reçoit sur UDP 514 et TCP 601 (logs), TCP 602 (alertes Wazuh). Les sources
(nginx, backend, Traefik, SSH, Suricata, ES, Kibana) lui envoient tout ; il
pousse vers Elasticsearch et recopie vers Wazuh.

```sh
docker exec syslog-ng syslog-ng-ctl stats | grep -E 'dst.*(written|dropped)'
# attendu : des compteurs "written" qui montent, "dropped" à 0
```

### 3. Wazuh manager (détection)

Analyse la copie des logs et écrit ses alertes dans `alerts.json`, relues par le
sidecar `wazuh-log-agent`.

```sh
docker exec wazuh-manager /var/ossec/bin/wazuh-control status
# attendu : wazuh-analysisd, wazuh-remoted (et wazuh-maild si notifications) "running"
docker exec wazuh-manager sh -c 'wc -l /var/ossec/logs/alerts/alerts.json'
# attendu : des alertes (dont l'audit SCA au démarrage)
```

Tester une règle sans attaque réelle, avec le banc d'essai intégré :

```sh
echo 'Oct 10 00:00:00 host sshd: Invalid user toto from 10.0.0.9' \
  | docker exec -i wazuh-manager /var/ossec/bin/wazuh-logtest
```

### 4. Suricata (IDS réseau)

Écoute le pont de la zone publique (`soc-public`) et écrit ses alertes en JSON ;
syslog-ng les transmet à Wazuh, qui les décode (règles SOC montées à niveau 10).

```sh
docker exec $(docker ps -qf name=suricata-1) \
  grep -E 'rules.*loaded|Engine started' /var/log/suricata/suricata.log
# attendu : "N rules successfully loaded, 0 rules failed" et "Engine started"
```

### 5. Kibana (visualisation)

Servi par le Traefik admin sur la boucle locale uniquement :
http://kibana.localhost:8080. Le service `kibana-setup` importe
automatiquement les dashboards et les *data views* (`syslog-*`,
`wazuh-alerts-4.x-*`).

```sh
curl -s -H 'Host: kibana.localhost' http://127.0.0.1:8080/api/status \
  | grep -o '"level":"available"'
# attendu : "level":"available"
```

## Pièges connus

- **Recharger la config de Wazuh** : `ossec.conf`, décodeurs et règles sont
  *montés* dans le conteneur. Un simple `restart` ne suffit pas, il faut
  **recréer** le conteneur pour que la config montée soit reprise :
  ```sh
  docker compose up -d --force-recreate wazuh-manager
  ```
- **Recréer syslog-ng seul** : nginx résout `syslog-ng` une seule fois au
  démarrage ; si on recrée syslog-ng, redémarrer aussi nginx.
- **Podman** : l'isolation réseau est équivalente, mais l'équipe l'a surtout
  validé sous Docker. Sous Podman rootless, pointer le socket et vérifier les
  noms de conteneurs (`podman compose ps`). De plus, **Suricata ne
  démarre pas sous Podman rootless** (capture AF_PACKET refusée) : les familles 1
  et 2, qui dépendent de ses signatures, n’apparaissent alors pas - basculer
  sous Docker pour les voir.
- **Windows (Docker Desktop)** : cloner avec des fins de ligne **LF** (pas CRLF),
  sinon les scripts d'entrée (`entrypoint.sh`) et certaines configs cassent.
- **Repartir de zéro** : `docker compose down -v` supprime **les volumes** (tous
  les logs et alertes stockés). À n'utiliser que pour une démo propre.
