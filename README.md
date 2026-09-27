# 8inf857projet1

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