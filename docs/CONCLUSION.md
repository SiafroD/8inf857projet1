# Analyse, limites et perspectives

## Ce qui marche

La chaîne **collecte → détection → stockage → visualisation → alerte** est
complète et de bout en bout :

- **Collecte centralisée** par syslog-ng de tous les services (web, base, SSH,
  réseau, et la pile elle-même), en zones réseau isolées.
- **Détection** par Wazuh, enrichie par **Suricata** (IDS réseau) dont les
  alertes sont décodées et remontées à niveau 10 pour nos signatures.
- **Contrôle d'intégrité (FIM)** par un agent Wazuh sur le serveur SSH, et
  **journalisation PostgreSQL** collectée : les deux scénarios de persistance
  sont désormais vus (voir plus bas).
- **Une seule base**, Elasticsearch, qui stocke logs bruts *et* alertes.
- **Visualisation** par des dashboards Kibana : une vue analyste globale plus un
  dashboard par famille d'attaque.
- **Notification** par courriel sur incident confirmé, *ciblée* sur les règles
  qui comptent (force brute, rôle pirate en base) pour ne pas noyer l'alerte
  grave sous le bruit de scan.

## Démarche : test en aveugle, puis fermeture des trous

Nous avons évalué la détection par un **test en aveugle** : un analyste a joué
les dix scénarios et cherché à les retrouver *uniquement* depuis Kibana. Le
premier passage a montré que la détection par **signature** voit le connu mais
laissait plusieurs attaques invisibles ; la blue team a ensuite fermé une partie
de ces trous. État après cette boucle :

| Attaque | Vue ? | Comment |
|---|---|---|
| Scan web, injections SQL | **Oui** | signatures Suricata (règles SOC) |
| Force brute SSH | **Oui** | échecs `sshd` décodés par Wazuh ; la rafale suivie du bon mot de passe lève une alerte « compte compromis » (règle 40112, niveau 12) |
| Persistance SSH (clé, profil) | **Oui, fermé** | agent Wazuh + FIM temps réel sur `/home/sysadmin/.ssh` et `.bashrc` |
| Persistance en base (rôle pirate) | **Oui, fermé** | journalisation DDL PostgreSQL + règle sur `CREATE/ALTER ROLE ... SUPERUSER` |
| Scan de ports | Non | flux Suricata présents, aucune règle ne les exploite |
| Altération des logs (silence, flood) | Non | aucune règle ne guette une source qui se tait ou un pic de volume |
| Force brute *web* (backend) | Partiel | les échecs sont journalisés, mais pas de règle de corrélation « N échecs » côté backend |

Le constat de fond ne change pas : **un dashboard ne montre que ce qu'on lui a
appris à chercher.** Fermer un trou = écrire une détection de plus. Une attaque
sans règle ne produit aucune alerte ; elle n'existe que dans les logs bruts,
qu'il faut fouiller à la main.

Autres limites :

- **Double comptage** : une requête traverse Traefik *et* nginx, et Suricata la
  voit sur deux segments ; une attaque génère donc beaucoup d'événements (les
  dashboards agrègent par type pour atténuer l'effet à l'affichage).
- **Sans agent partout**, les alertes issues de la seule copie syslog portent le
  même `agent.name` (`wazuh-manager`) ; on distingue l'origine par le nom de
  programme. Le serveur SSH, lui, a un vrai agent (`ssh`).
- **Labo, pas production** : sécurité Elasticsearch désactivée, mots de passe
  faibles volontaires, Mailpit à la place d'un vrai SMTP, enrôlement d'agent
  Wazuh sans mot de passe.

## Retour sur nos choix

Avec le recul, réimplémenter la stack syslog-ng → Elasticsearch → Kibana à côté
de Wazuh est un peu redondant : Wazuh embarque déjà sa propre stack ELK, et dans
un vrai déploiement on l'aurait sans doute utilisée directement plutôt que d'en
monter une deuxième. Tout faire en conteneurs nous a aussi demandé plus de mise
au point que des machines virtuelles où on installe les services à la main, même
si au final c'est plus reproductible.

## Ce qui reste à faire

Dans l'ordre de valeur :

1. **Règle sur les flux Suricata** pour le scan de ports.
2. **Détection d'absence / de volume** pour l'altération des logs (voir
   perspectives).
3. **Règle de corrélation backend** « N échecs puis un succès » → compte web
   compromis.

## Perspectives (veille technologique)

- **Détection par anomalie / ML** : pour voir *l'inconnu*, retourner la logique —
  au lieu de chercher le connu-mauvais, faire ressortir l'anormal (pic ou chute
  de volume d'une source, programme jamais vu). La **détection d'anomalie
  d'Elastic** (jobs ML) va dans ce sens ; elle signalerait l'inondation et le
  silence sans aucune règle. Elle demande une licence d'essai (hors Basic) et,
  pour rester dans le rendu, doit être livrée comme configuration versionnée, pas
  créée à la main dans l'UI.
- **Plusieurs points de vue** : un conteneur compromis peut couper *ses* logs
  (scénario 4a), mais pas son trafic réseau — Suricata continue de le voir.
  Croiser hôte (Wazuh) et réseau (Suricata) réduit l'angle mort qu'une seule
  source laisse.
- **Agents Wazuh** sur plus d'hôtes (intégrité, inventaire, réponse active :
  bloquer une IP automatiquement).
- **Orchestration** : faire tourner l'ensemble sur un cluster Kubernetes pour
  le passage à l'échelle et la résilience.
- **Enrichissement** : géolocalisation des IP, corrélation inter-sources,
  tableaux de conformité (PCI-DSS déjà fournis par Wazuh).
