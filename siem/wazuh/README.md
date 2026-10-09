# Wazuh

On n'utilise que le **Wazuh manager** : il analyse les logs et écrit ses alertes dans `/var/ossec/logs/alerts/alerts.json`.

## Pourquoi l'intégration « Wazuh server » et pas « Wazuh indexer »

La doc Wazuh ([Elastic Stack integration](https://documentation.wazuh.com/current/integrations-guide/elastic-stack/index.html)) propose deux options :

- **Wazuh indexer** : on garde la base de Wazuh (un fork d'OpenSearch) et on recopie ses alertes dans Elasticsearch. Ça fait deux bases qui stockent la même chose.
- **Wazuh server** : on lit directement `alerts.json` sur le manager et on l'envoie dans Elasticsearch.

On voulait **une seule base de données** (Elasticsearch), donc on a pris l'option **Wazuh server**.

La doc utilise Logstash pour lire le fichier ; nous, on utilise **syslog-ng**, qui fait déjà la collecte dans ce projet.

## Le flux

syslog-ng envoie au manager une copie de tous les logs qu'il reçoit (syslog TCP 514, réseau `data` seulement). Wazuh n'écrit ses alertes que dans un fichier, `alerts.json` (sa seule sortie réseau, `syslog_output`, est en UDP et perd des alertes). Comme pour Elasticsearch et Kibana, un sidecar, `wazuh-log-agent`, lit ce fichier (volume en lecture seule) et l'envoie au syslog-ng central en TCP 602. Le central pousse chaque alerte telle quelle dans Elasticsearch, index `wazuh-alerts-4.x-AAAA.MM.JJ`.

Le port 602 ne sert qu'aux alertes : elles ne repartent jamais vers Wazuh, et seul le réseau `data` peut y écrire.

Le template `wz-es-4.x-8.x-template.json` est installé avant le démarrage de syslog-ng (service `wazuh-template`), et `kibana-setup` importe les dashboards Wazuh.

Le Filebeat de l'image (fichier `filebeat-down`) et la détection de vulnérabilités sont coupés : ils visent un Wazuh indexer, que ce lab n'a pas.
