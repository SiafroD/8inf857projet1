# Analyse, limites et perspectives

## Ce qui marche

La chaîne **collecte → détection → stockage → visualisation → alerte** est
complète et de bout en bout :

- **Collecte centralisée** par syslog-ng de tous les services (web, base, SSH,
  réseau, et la pile elle-même), en zones réseau isolées.
- **Détection** par Wazuh, enrichie par **Suricata** (IDS réseau) dont les
  alertes sont décodées et remontées à niveau 10 pour nos signatures.
- **Une seule base**, Elasticsearch, qui stocke logs bruts *et* alertes.
- **Visualisation** par deux dashboards Kibana, dont une vue condensée par type
  d'attaque.
- **Notification** par courriel sur intrusion confirmée (niveau ≥ 10).

## Limites : ce que le SIEM ne voit pas

Nous avons évalué la détection par un **test en aveugle** : un analyste a joué
les dix scénarios et cherché à les retrouver *uniquement* depuis Kibana. Résultat
honnête : la détection par **signature** voit le connu, mais reste aveugle à
plusieurs attaques.

| Attaque | Vue dans les alertes ? | Pourquoi |
|---|---|---|
| Scan web, injections SQL, force brute | **Oui** | règles Suricata/Wazuh existantes |
| Scan de ports | Non | flux Suricata présents mais non exploités par une règle |
| Altération des logs (silence, flood) | Non | aucune règle ne guette une source qui se tait ou un pic |
| Persistance SSH (clé, profil) | Non | demande le *contrôle d'intégrité de fichiers* (FIM), donc un agent Wazuh sur l'hôte |
| Persistance en base (rôle pirate) | Non | PostgreSQL ne journalise rien par défaut, et ses logs ne sont pas collectés |

Le constat de fond : **un dashboard ne montre que ce qu'on lui a appris à
chercher.** Une attaque sans règle ne produit aucune alerte, donc n'apparaît pas
— elle n'existe que dans les logs bruts, qu'il faut fouiller à la main.

Autres limites :

- **Sans agent Wazuh**, toutes les alertes portent le même `agent.name`
  (`wazuh-manager`) ; on distingue l'origine par le nom de programme, pas par un
  hôte propre.
- **Double comptage** : une requête traverse Traefik *et* nginx, et Suricata la
  voit sur deux segments ; une attaque génère donc beaucoup d'événements (la vue
  condensée atténue l'effet à l'affichage).
- **Labo, pas production** : sécurité Elasticsearch désactivée, mots de passe
  faibles volontaires, Mailpit à la place d'un vrai serveur SMTP.

## Améliorations possibles

Fermer les angles morts, dans l'ordre de valeur :

1. **Journaliser PostgreSQL** (`log_statement`) et collecter ses logs → détecter
   la création d'un rôle/d'un superutilisateur (persistance en base).
2. **Agent Wazuh + FIM** sur le serveur SSH → détecter la clé et le profil shell
   déposés (persistance SSH), et donner un vrai `agent.name`.
3. **Règle de corrélation backend** « N échecs puis un succès » → signaler un
   compte compromis, que les échecs seuls ne montrent pas.
4. **Règle sur les flux Suricata** pour le scan de ports.

## Perspectives (veille technologique)

- **Détection par anomalie / ML** : pour voir *l'inconnu*, retourner la logique —
  au lieu de chercher le connu-mauvais, faire ressortir l'anormal (pic ou chute
  de volume d'une source, programme jamais vu). La **détection d'anomalie
  d'Elastic** (jobs ML) va dans ce sens ; elle aurait signalé l'inondation et le
  silence sans aucune règle. Elle demande une licence d'essai (hors Basic).
- **Agents Wazuh** sur les hôtes pour l'intégrité de fichiers, l'inventaire et la
  réponse active (bloquer une IP automatiquement).
- **Réponse automatisée** (active response Wazuh) et notifications multi-canal
  (Slack/Teams) au-delà du courriel.
- **Enrichissement** : géolocalisation des IP, corrélation inter-sources,
  tableaux de conformité (PCI-DSS déjà fournis par Wazuh).
