# Système de détection d'anomalies et de gestion de logs

Projet pratique 1 — 8INF857. Un petit SIEM qui collecte les logs d'un réseau
simulé, les analyse pour détecter des intrusions, les stocke, les visualise, et
notifie l'administrateur sur un cas confirmé.

## Objectif

Monter une chaîne complète **collecte → détection → stockage → visualisation →
alerte**, puis la mettre à l'épreuve avec cinq familles d'attaques et montrer
leur détection.

## Outils

| Rôle | Outil |
|---|---|
| IDS/IPS | **Wazuh** (manager) + **Suricata** (capteur réseau) |
| Collecteur de logs | **syslog-ng** |
| Base de données | **Elasticsearch** |
| Visualisation | **Kibana** |

Choix assumé : **une seule base, Elasticsearch**. On n'installe ni le Wazuh
indexer ni le Wazuh dashboard — Wazuh se limite au *manager* et ses alertes sont
poussées dans Elasticsearch par syslog-ng (voir [`siem/wazuh/README.md`](siem/wazuh/README.md)).

## Architecture

Le labo est découpé en **zones réseau isolées** : un service ne peut joindre que
ce dont il a besoin. Toutes les sources envoient leurs logs au **syslog-ng
central**, qui en garde une copie dans Elasticsearch (`syslog-*`) et en envoie
une autre à Wazuh ; les alertes de Wazuh repartent dans Elasticsearch
(`wazuh-alerts-4.x-*`) et s'affichent dans Kibana.

```mermaid
flowchart LR
    Attaquant([Internet / attaquant])
    Analyste([Analyste SOC<br/>tunnel ou VPN])

    subgraph prod["prod/ : zone publique"]
        TP["traefik-public<br/>:80"]
        NG["nginx<br/>site vitrine"]
        BK["backend<br/>login + recherche"]
        DB[("base<br/>produits + users")]
        SSH["serveur SSH<br/>(cible)"]
        SUR["Suricata<br/>capteur du pont public"]
        APub["agent syslog-ng<br/>logs Traefik, SSH, Suricata"]
    end

    subgraph admin["admin/ : entrée interne"]
        TA["traefik-admin<br/>127.0.0.1:8080"]
        AAdm["agent syslog-ng<br/>log d'accès Traefik"]
    end

    subgraph siem["siem/ : SIEM"]
        SL["syslog-ng<br/>UDP 514 · TCP 601 · TCP 602"]
        ES[("Elasticsearch<br/>index syslog-* et wazuh-alerts-*")]
        KB["Kibana<br/>+ dashboards importés"]
        AG["agents syslog-ng<br/>logs d'ES et de Kibana"]
        WZ["Wazuh manager<br/>analyse les logs"]
        AWZ["agent syslog-ng<br/>alertes Wazuh"]
    end

    Attaquant -->|"HTTP :80"| TP
    Attaquant -.->|"SSH"| SSH
    TP -->|"réseau public"| NG
    NG -->|"/api · réseau app"| BK
    BK -->|"réseau db"| DB
    NG -->|"logs UDP 514<br/>réseau logs"| SL
    BK -->|"logs applicatifs UDP 514<br/>réseau logs"| SL
    AG -->|"TCP 601<br/>réseau data"| SL
    TP -.->|"volume"| APub
    SSH -.->|"volume"| APub
    SUR -.->|"volume"| APub
    SUR -.->|"observe le pont"| TP
    APub -->|"TCP 601<br/>réseau logs"| SL
    TA -.->|"volume"| AAdm
    AAdm -->|"TCP 601<br/>réseau data"| SL
    SL -->|"_bulk HTTP<br/>réseau data"| ES
    KB -->|"réseau data"| ES
    Analyste -->|"kibana.localhost:8080"| TA
    TA -->|"réseau admin"| KB
    SL -->|"copie des logs<br/>syslog TCP 514<br/>réseau data"| WZ
    WZ -.->|"volume<br/>alerts.json"| AWZ
    AWZ -->|"TCP 602<br/>réseau data"| SL
```

Le fichier source du schéma : [`architecture.mmd`](architecture.mmd).

## Structure du dépôt

```
docker-compose.yml     # la carte : inclut les 3 zones et déclare les réseaux
prod/                  # zone publique : traefik, nginx, backend, base, ssh, suricata
admin/                 # entrée interne : traefik-admin -> Kibana (loopback)
siem/                  # le SIEM : syslog-ng, Elasticsearch, Kibana, Wazuh, agents
  elasticsearch/  kibana/  syslog-ng/  wazuh/  kibana-export/
attacks/               # red team : 5 familles x 2 scénarios + run.sh
docs/                  # cette documentation
```

## Démarrage

Prérequis et vérifications détaillés : [`docs/INSTALLATION.md`](docs/INSTALLATION.md).

```sh
docker compose up -d        # ou : podman compose up -d
```

Puis, depuis la machine hôte :

- **Kibana** : http://kibana.localhost:8080 (via Traefik admin, loopback seulement)
- **Site attaqué** : http://localhost
- **Serveur SSH cible** : `ssh -p 2222 sysadmin@localhost`

## Tester et visualiser

- Jouer les attaques : [`docs/UTILISATION.md`](docs/UTILISATION.md) et [`attacks/README.md`](attacks/README.md).
- Lire les dashboards : [`docs/VISUALISATION.md`](docs/VISUALISATION.md).
- Analyse, limites et perspectives : [`docs/CONCLUSION.md`](docs/CONCLUSION.md).
