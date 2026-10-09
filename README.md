# 8inf857projet1

## Prérequis

Avoir Docker Compose d'installé

## Architecture du projet

Le projet est structuré de la façon suivante : 
- Un fichier `docker-compose.yml` définissant les différents réseaux et les services utilisés.
- Un dossier `etc` contenant les fichiers de configuration des différents services.
- Un playbook Ansible permettant l'installation et la configuration de syslog-ng.

Comme nous avons travaillé avec des containers Docker, nous avons tout d'abord travaillé avec syslog-ng installé sur la machine hôte, qui agrégeait les logs remontés grâce à journald.

Cependant, comme cela ne reflétait pas une vraie architecture réseau classique (où syslog-ng serait installé dans un container à part et sur les différents services), nous avons décidé d'ajouter des Dockerfiles afin de modifier chaque image pour installer et configurer syslog-ng en local.

## Installation et configuration

### Syslog-ng

L'installation de syslog-ng peut se faire à la main 

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