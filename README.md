# 8inf857projet1

## Architecture du projet

### Architecture des fichiers

Le projet est structuré de la façon suivante : 
- Un fichier `docker-compose.yml` définissant les différents réseaux et les services utilisés.
- Un dossier `siem` contenant les Dockerfiles des différents services du SIEM ainsi que leur fichiers de configuration, avec un Docker Compose liant les services entre eux. On retrouve également à l'intérieur un dossier `kibana-export` contenant le fichier de configuration du dashboard Kibana personnalisé.
- Un dossier `prod` contenant les Dockerfiles et fichiers de configuration des services de production. Ces services sont ceux exposés sur Internet. Il contient également un Docker Compose afin de lancer tout ensemble.
- Un dossier `admin` contenant les Dockerfiles et fichiers de configuration des services administrateurs. 

### Services utilisés

Du côté du SIEM, on utilise syslog-ng comme agrégateur de logs, qui sont ensuite envoyés à ElasticSearch pour le stockage et la navigation. Wazuh récupère également les logs de syslog-ng et les analyse afin de lever des alertes, et les envoie vers ElasticSearch. L'affichage est ensuite réalisé par Kibana qui permet la navigation et l'affichage des alertes.

Dans le réseau prod, on retrouve à l'entrée un service Traefik qui récupère toutes les requêtes réalisées vers le reste des services dans ce réseau. Derrière, on a un serveur nginx avec un backend permettant l'authentification et la recherche d'objets dans une base de données. On retrouve également un service Suricata qui observe le port public de Traefik et qui classifie selon quelques règles (environ 53000) si une requête est bénine ou mauvaise. 

Le réseau admin contient également un Traefik et permet de se connecter au dashboard Kibana depuis l'extérieur.

Afin de refléter une architecture réseau classique, nous avons décidé d'installer syslog-ng en tant que sidecar, c'est-à-dire installé sur un container parallèle possédant un volume partagé avec le service observé. Ces instances sidecar agrègent les logs du service observé et les envoient vers le container syslog-ng central situé dans le SIEM.

Pour une représentation plus visuelle : voir **architecture.mmd**.

### Choix des services

Mis à part les services obligatoires (syslog-ng, ElasticSearch, Kibana), voici les motivations qui nous ont poussés à choisir les différents services :
- **Wazuh** : Nous avons décidé d'implémenter Wazuh plutôt que Snort par souci de familiarité. En effet, nous étions plusieurs du groupe à avoir déjà travaillé avec Wazuh.
- **Suricata** : Suggéré dans le sujet, nous avons voulu l'implémenter afin de rajouter des règles d'alertes en plus de Wazuh.
- **Traefik** : Traefik nous permettait de combiner un proxy avec un outil de logging supplémentaire, afin de rajouter ceux-ci aux logs déjà présents.

> Attention: Suricata ne peut pas écouter sur l'interface physique de l'hôte en Docker rootless ou sur Podman par manque de permissions. Il est donc nécessaire de le brancher directement sur le Traefik/nginx.

Nous avons également choisi d'implémenter des applications pouvant servir de cibles aux scénarios d'attaque. Nous avons donc mis en place un serveur web nginx ainsi qu'un serveur SSH.


## Installation et configuration

### Lancement de l'architecture globale

Le projet se base sur des images Docker récupérées sur le Docker Hub. Il n'y a donc pas d'installation à réaliser mis à part celles demandées pour lancer le projet.

Afin de pouvoir lancer le projet il faut :
- Une connexion Internet
- Docker et Docker Compose ou Podman

Afin de lancer le projet : 

**Docker :**
```bash
docker compose up
```

**Podman :**
```bash
podman compose up
```

Une fois les services lancés, accéder au dashboard Kibana sur la page `http://kibana.localhost:8080`.

Normalement le dashboard est déjà importé au démarrage.
Pour y accéder : Menu vertical en haut à gauche -> **Analytics** : Dashboard

Si le dashboard personnalisé ne s'est pas importé :
Menu vertical en haut à gauche -> **Management** : Stack Management -> **Kibana** : Saved Objects -> Import -> Sélectionner le fichier .ndjson -> Import -> Done
Juste après l'import : Cliquer sur **Dashboard Project 1** 

### Scénarios d'attaque

Les différents scénarios et la justification du choix sont indiqués dans `attacks/README.md`.

### Visualisation des logs d'alerte


## Analyse et conclusion

Tout d'abord, il a été noté par les membres du groupe que réimplémenter la stack syslog-ng - ElasticSearch - Kibana était relativement contre-productif. En effet, il aurait été plus simple dans une architecture de prod d'implémenter directement Wazuh, qui se base déjà sur la stack ELK. 

En terme de limites, faire le projet sous Docker rendait un peu plus complexe la mise en place du projet que le déploiement de machines virtuelles sur lesquelles il serait possible d'installer des services directement.

Une amélioration possible serait de faire tourner l'ensemble du projet sur un noeud Kubernetes.

## Utilisation de l'intelligence artificielle

Le travail est élaboré en partenariat avec l’IA générative. Le contenu a été en partie généré ou reformulé par celle-ci.
