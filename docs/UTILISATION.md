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

- **Famille 1 … 5** : un dashboard par famille d'attaque, avec le détail de ses
  sous-scénarios.
- **SOC – Vue analyste** : la vue d'ensemble (volume, gravité, MITRE, top règles
  / IP / services).
- **Attaques par type** : une vue condensée transverse, une ligne = un type
  d'incident.

Lecture détaillée : [`VISUALISATION.md`](VISUALISATION.md).

## 3. La notification

Sur un **incident confirmé**, Wazuh envoie un **courriel**, reçu dans le labo par
**Mailpit** (sans compte ni serveur externe), sur **http://127.0.0.1:8025**.
L'envoi est ciblé : seuil global niveau ≥ 12, plus un envoi forcé sur la force
brute et sur la création d'un rôle pirate en base. Le bruit de scan (niveau 10)
ne génère pas de mail.

Déclencher et vérifier, par exemple avec le rôle pirate en base (niveau 12) :

```sh
sh attacks/run.sh 05-persistence/b-database
# puis ouvrir http://127.0.0.1:8025 : un mail Wazuh « rôle SUPERUSER créé »
```

Configuration et seuil : [`../siem/wazuh/README.md`](../siem/wazuh/README.md)
(section *Notifications*).

## 4. Correspondance attaque → détection

Où chaque scénario se voit, aujourd'hui :

| Scénario | Détecté par | Où le voir |
|---|---|---|
| 1a. scan web | Suricata (règles SOC, niv 10) | alerte + dashboard Reconnaissance |
| 1b. scan de ports | — *(angle mort)* | logs bruts Suricata (`syslog-*`) |
| 2a/2b. injection SQL | Suricata (règle SOC) | alerte + dashboard Injection SQL |
| 3a. force brute SSH | Wazuh (échecs `sshd`) + Suricata | alerte + dashboard Force brute |
| 3b. force brute web | échecs journalisés *(pas de corrélation)* | logs bruts / alerte d'échec |
| 4a. silence / 4b. flood | — *(angle mort)* | logs bruts, volume anormal (dashboard Famille 4) |
| 5a. persistance SSH | **Wazuh FIM** (agent sur le serveur SSH) | alerte + dashboard Persistance |
| 5b. persistance base | **Wazuh** (journal PostgreSQL + règle rôle) | alerte + dashboard Persistance |

> Suricata écoute le pont réseau et exige le mode Docker (ou `NET_RAW`) : sous
> Podman rootless il ne démarre pas, et les familles **1 et 2** (qui dépendent de
> ses signatures) n'apparaissent alors pas. Les familles 3, 4 et 5 reposent sur
> Wazuh et marchent dans les deux cas.

Les angles morts restants et les pistes pour les fermer sont expliqués dans
[`CONCLUSION.md`](CONCLUSION.md).
