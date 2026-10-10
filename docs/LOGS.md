# Quels logs pour quel scénario, et pourquoi

On ne garde pas les logs au hasard : selon le type d'attaque, la trace se trouve
dans des logs bien précis. Une reconnaissance ne laisse rien dans les logs
d'authentification, une persistance ne laisse rien dans le trafic réseau, et
ainsi de suite. Voici, famille par famille, les logs qu'on considère
prioritaires et la raison.

Tous passent par le même chemin (les sidecars syslog-ng → le syslog-ng central →
Elasticsearch, avec une copie vers Wazuh pour l'analyse). Ce qui change d'un
scénario à l'autre, ce n'est pas le chemin, c'est *où regarder*.

## 1. Reconnaissance (scan web, scan de ports)

Logs prioritaires : les **logs d'accès HTTP** (nginx et Traefik) et les **flux
réseau** vus par Suricata.

Pourquoi : un scan ne s'authentifie pas et n'exploite encore rien, il ne laisse
donc aucune trace côté authentification ou base de données. Ce qui le trahit,
c'est le comportement : une rafale de requêtes vers des chemins qui n'existent
pas (beaucoup de 404), un User-Agent d'outil connu (Nikto, sqlmap), ou côté
réseau un grand nombre de connexions vers des ports différents depuis une même
IP. D'où l'importance des logs d'accès et du capteur réseau pour cette famille.

## 2. Injection SQL (recherche, login)

Logs prioritaires : les **logs d'accès** (l'URL contient la charge utile), les
**logs du backend** (la requête reçue et l'erreur éventuelle) et la **signature
Suricata** sur le motif d'injection.

Pourquoi : l'attaque voyage dans la requête HTTP, donc elle est visible là où la
requête arrive — le proxy et l'application. On met le backend en priorité parce
que c'est lui qui voit le paramètre tel qu'il est réellement utilisé, et c'est
aussi là qu'une injection *réussie* se verrait (erreur SQL, réponse anormale).

## 3. Force brute (SSH, login web)

Logs prioritaires : les **logs d'authentification** — `sshd` pour le SSH, le
backend pour le login web.

Pourquoi : un échec isolé n'est rien, c'est la répétition qui fait l'attaque. Les
logs d'auth, avec l'IP source, sont donc les seuls à compter, et c'est Wazuh qui
corrèle : plusieurs échecs rapprochés, et surtout une série d'échecs **suivie
d'un succès** (règle 40112), qui signale un compte probablement compromis.

## 4. Conteneur compromis (silence, inondation)

Log prioritaire : le **flux de logs lui-même**, c'est-à-dire son volume par
source dans le temps.

Pourquoi : ici l'attaquant s'en prend à la journalisation. Le contenu d'un
message ne sert à rien si la source se tait (plus aucun log) ou inonde (des
milliers de faux logs). Ce qui compte, c'est la forme du flux : une chute de
volume = un silence suspect, un pic = une inondation. On surveille donc le
pipeline de collecte, pas le texte des messages — c'est tout l'intérêt du
tableau de bord « Famille 4 », qui lit `syslog-*` et pas les alertes.

## 5. Persistance (clé SSH + profil shell, rôle en base)

Logs prioritaires : les **événements d'intégrité de fichiers (FIM)** sur
`~/.ssh/authorized_keys` et `~/.bashrc`, et les **logs DDL de PostgreSQL**
(`CREATE` / `ALTER ROLE`).

Pourquoi : une porte dérobée est un changement d'état sur le disque ou dans la
base, pas un événement réseau. Elle n'apparaît que si on surveille les fichiers
sensibles (l'agent Wazuh le fait en temps réel) et si la base journalise les
modifications de rôles. Sans ces deux sources, la persistance est invisible —
c'est exactement ce qu'on a constaté lors de notre premier test en aveugle, avant
d'ajouter le FIM et la journalisation de la base.
