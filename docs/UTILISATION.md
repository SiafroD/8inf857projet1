# Guide d'utilisation : jouer et observer les attaques

Le dépôt fournit une **red team** (`attacks/`) qui joue les intrusions, et une
**blue team** (le SIEM) qui doit les détecter. Ce guide explique comment lancer
les scénarios et où voir la détection.

## 1. Lancer les attaques

Les scripts tournent depuis un petit conteneur « attaquant » posé sur le réseau
visé ; aucun outil à installer sur l'hôte.

```sh
sh attacks/run.sh                       # joue les 10 scénarios dans l'ordre
sh attacks/run.sh 03-bruteforce/a-ssh   # joue un seul scénario
```

Les cinq familles (deux sous-scénarios chacune) — détail dans
[`../attacks/README.md`](../attacks/README.md) :

| Famille | a | b |
|---|---|---|
| 1. Reconnaissance | scan web (Nikto/sqlmap) | scan de ports (nmap) |
| 2. Injection SQL | sur la recherche | sur le login |
| 3. Force brute | SSH | login web |
| 4. Conteneur compromis | coupe sa télémétrie | inonde les logs |
| 5. Persistance | clé SSH + profil shell | rôle pirate en base |

> Les scénarios 4 et 5 modifient l'état du labo (un agent de logs arrêté, un rôle
> en base, 5000 faux logs). Pour une démo propre ensuite : `docker compose down -v`
> puis `up -d` (voir INSTALLATION). Relancer un agent arrêté :
> `docker compose up -d ssh-log-agent`.

## 2. Voir la détection dans Kibana

Ouvrir **http://kibana.localhost:8080**.

### Les deux sources de données (*data views*)

| Data view | Contenu |
|---|---|
| `wazuh-alerts-4.x-*` | les **alertes** (ce que Wazuh/Suricata jugent suspect) |
| `syslog-*` | **tous les logs bruts** de tous les services |

Dans **Discover**, choisir la data view puis filtrer. Exemples (langage KQL) :

- Toutes les alertes d'intrusion, sans le bruit de l'auto-audit de Wazuh :
  `NOT rule.groups: sca`
- Les cas graves (intrusion confirmée) : `rule.level >= 10`
- Par attaquant : `data.srcip: "10.201.1.5"`
- Les logs bruts d'un service : `process.name: "nginx"` (dans `syslog-*`)

### Les dashboards

Menu **Dashboards** :

- **Wazuh – Vue d'ensemble** : la vue SOC générale (volume, gravité, MITRE, top
  règles).
- **Wazuh – Attaques par type** : une section **condensée** par famille — une
  ligne = un type d'incident, pas vingt logs.

Lecture détaillée : [`VISUALISATION.md`](VISUALISATION.md).

## 3. La notification

Dès qu'une alerte de **niveau ≥ 10** tombe (intrusion confirmée), Wazuh envoie un
**courriel**. Dans le labo, il est reçu par **Mailpit**, un collecteur sans compte
ni serveur externe, consultable sur **http://127.0.0.1:8025**.

Déclencher et vérifier, par exemple avec le scan web :

```sh
sh attacks/run.sh 01-recon/a-web-scan
# puis ouvrir http://127.0.0.1:8025 : un mail "Wazuh notification - Alert level 10"
```

Configuration et seuil : [`../siem/wazuh/README.md`](../siem/wazuh/README.md)
(section *Notifications*).

## 4. Correspondance attaque → détection

Où chaque scénario se voit, aujourd'hui :

| Scénario | Détecté par | Où le voir |
|---|---|---|
| 1a. scan web | Suricata (règles SOC, niv 10) + nginx | alerte + dashboard Attaques |
| 1b. scan de ports | — *(angle mort)* | logs bruts Suricata (`syslog-*`) |
| 2a/2b. injection SQL | Suricata + nginx | alerte |
| 3a. force brute SSH | Wazuh (sshd) + Suricata | alerte |
| 3b. force brute web | échecs loggés | logs bruts / alerte d'échec |
| 4a. silence / 4b. flood | — *(angle mort)* | logs bruts, volume anormal |
| 5a. persistance SSH / 5b. base | — *(angle mort)* | voir CONCLUSION |

Les angles morts et les pistes pour les fermer sont expliqués dans
[`CONCLUSION.md`](CONCLUSION.md).
