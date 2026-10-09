# 8inf857projet1

## Architecture du projet

Le projet est structuré de la façon suivante : 
- Un fichier `docker-compose.yml` définissant les différents réseaux et les services utilisés.
- Un dossier `siem` contenant les Dockerfiles des différents services du SIEM ainsi que leur fichiers de configuration, avec un Docker Compose liant les services entre eux. On retrouve également à l'intérieur un dossier `kibana-export` contenant le fichier de configuration du dashboard Kibana personnalisé.
- Un dossier `prod` contenant les Dockerfiles et fichiers de configuration des services de production. Ces services sont ceux exposés sur Internet. Il contient également un Docker Compose afin de lancer tout ensemble.
- Un dossier `admin` contenant les Dockerfiles et fichiers de configuration des services administrateurs. 

Les réseaux admin et prod comportent tous deux un service Traefik observant toutes les requêtes entrante et les faisant passer à syslog-ng.

Afin de refléter une architecture réseau classique, nous avons décidé d'installer syslog-ng en tant que sidecar, c'est-à-dire installé sur un container parallèle possédant un volume partagé avec le service observé. Ces instances sidecar agrègent les logs du service observé et les envoient vers un container syslog-ng qui envoie tout ces logs à ElasticSearch.

Kibana peut ensuite accéder aux logs d'ElasticSearch et les visualiser.

## Installation et configuration

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

Une fois les services lancés, accéder au dashboard Kibana sur la page `http://kibana.localhost:5601`.

Pour importer le dashboard personnalisé sur Kibana :
Menu vertical en haut à gauche -> **Management** : Stack Management -> **Kibana** : Saved Objects -> Import -> Sélectionner le fichier .ndjson -> Import -> Done

Pour ouvrir le dashboard :
Juste après l'import : Cliquer sur **Dashboard Project 1** 

Architecture du projet : 

**Outils à utiliser** :
- IDS/IPS : exemple Wazuh
- Collecteur de logs : exemple syslog-ng
- BDD pour la gestion des logs : exemple Elasticsearch
- Interface utilisateur pour la visualisation des logs : exemple Kibana


**Architecture globale demandée** : 
- syslog-ng collecte des logs
- Les logs sont envoyés à Elasticsearch pour l'analyse
- Wazuh analyse les logs pour détecter les anomalies et les menaces
- Kibana propose une GUI pour visualiser le tout

**Test de l'architecture** :
5 cas différents d'intrusion et montrer la détection des intrusions
Exemples ?
- Bruteforce d'un endpoint avec authentification (port SSH avec authentification par mot de passe, site web)
- Requête malveillante -> Question : Y a-t-il besoin d'implémenter des services supplémentaires dans lesquels on plante des vulnérabilités ?
- Autres : peut-être regarder pour utiliser Caldera ?
