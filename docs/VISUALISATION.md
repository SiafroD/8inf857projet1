# Visualisation (Kibana)

Toute la visualisation passe par **Kibana**, servi sur la boucle locale via le
Traefik admin : **http://kibana.localhost:8080**. Les dashboards et les *data
views* sont importés automatiquement au démarrage (`kibana-setup` charge tous les
fichiers de `siem/kibana-export/`).

## Un dashboard par famille d'attaque

Cinq dashboards, un par famille (`Famille 1 – Reconnaissance` … `Famille 5 –
Persistance`). Chacun donne le détail de sa famille : compteurs, activité dans le
temps par service, et un tableau **condensé** par sous-scénario (une ligne = un
type d'incident, pas les dizaines de logs qu'une attaque génère).

Tous lisent l'index des alertes `wazuh-alerts-4.x-*`, **sauf** « Famille 4 –
Altération des logs » : un conteneur qui se tait ou qui inonde ne produit
*aucune* alerte, donc ce dashboard lit les logs bruts `syslog-*` et montre le
**volume par source dans le temps** — un pic signale l'inondation, une chute le
silence.

## Dashboard « SOC – Vue analyste »

La vue d'ensemble, centrée alertes (`wazuh-alerts-4.x-*`).

![Dashboard Vue d'ensemble](images/dashboard-overview.png)

Comment la lire :

- **Les tuiles du haut** : nombre total d'alertes, alertes de niveau ≥ 10,
  échecs et succès d'authentification. Un coup d'œil sur l'état.
- **Alertes dans le temps, par service** : qui génère des alertes et quand ; un
  pic signale une rafale d'activité.
- **Tactiques MITRE ATT&CK** : les tactiques des attaquants (accès initial,
  accès aux identifiants, persistance…), utile pour qualifier la menace.
- **Top règles / top sources (IP) / top services visés** : le détail pour
  pivoter vers l'enquête.
- Un **filtre** « NOT … SCA » masque l'auto-audit que le manager fait de son
  propre conteneur (du bruit, pas une menace) ; un clic le réactive.

## Dashboard « Attaques par type »

Une vue **condensée** transverse : les alertes sont agrégées, donc une ligne
correspond à un type d'incident et non aux dizaines de logs d'une attaque. Une
tuile par famille donne le compte en un coup d'œil.

![Dashboard Attaques par type](images/dashboard-attaques.png)

Les familles **reconnaissance**, **injection SQL**, **force brute** et
**persistance** (SSH et base) y remontent. Restent à **0** les deux angles morts
encore ouverts — **scan de ports** et **altération des logs** — affichés
volontairement pour montrer ce que le SIEM ne voit *pas encore* (voir
[CONCLUSION](CONCLUSION.md)).

## Notification par courriel

Sur un incident confirmé, Wazuh envoie un courriel, reçu dans le labo par
**Mailpit** (http://127.0.0.1:8025).

![Notification reçue dans Mailpit](images/notification-mailpit.png)

L'envoi est **ciblé** : au-delà du seuil global (niveau ≥ 12), un courriel part
aussi sur la force brute composite et sur la création d'un rôle/superutilisateur
en base. Un simple hit de scan (niveau 10) ne déclenche pas de mail — il reste
dans Kibana — pour ne pas vider le quota horaire pendant une rafale. Le mail
contient la règle déclenchée, son niveau et l'extrait de log : l'administrateur
sait immédiatement quoi regarder.

> Les captures ci-dessus ont été prises après un jeu d'attaques de démonstration ;
> les chiffres varient selon ce qui a été joué. Le bandeau « Your data is not
> secure » de Kibana est un simple message de session (sécurité désactivée en
> labo) et disparaît d'un clic.
