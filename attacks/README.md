# Scénarios d'attaque (red team)

Cinq familles, deux sous-scénarios chacune. Chaque script joue l'attaque contre
le labo ; la détection est du ressort de la blue team.

| Famille | Sous-scénario | Script |
|---|---|---|
| 1. Reconnaissance | a. scan web | `01-recon/a-web-scan.sh` |
| | b. scan de ports | `01-recon/b-port-scan.sh` |
| 2. Injection SQL | a. sur la recherche | `02-sqli/a-search.sh` |
| | b. sur le login | `02-sqli/b-login.sh` |
| 3. Force brute | a. SSH | `03-bruteforce/a-ssh.sh` |
| | b. login web | `03-bruteforce/b-web-login.sh` |
| 4. Conteneur compromis | a. coupe sa télémétrie | `04-logging/a-silence.sh` |
| | b. inonde les logs | `04-logging/b-flood.sh` |
| 5. Persistance | a. serveur SSH | `05-persistence/a-ssh.sh` |
| | b. base de données | `05-persistence/b-database.sh` |

`./run.sh` joue tout, `./run.sh 03-bruteforce/a-ssh` un seul.

## Explications des attaques et des choix

### Reconnaissances

Les attaques de reconnaissance consistent à essayer de repérer la topologie (ici les pages web disponibles ou les ports ouverts) de la cible afin de s'y infiltrer par la suite. Ces attaques peuvent être intéressantes à détecter car elles représentent les prémices d'une attaque imminente, ou du moins elles permettent de montrer qu'un acteur porte un intérêt à nos actifs. Nous avons également trouvé ce scénario intéressant car il n'y a pas de vraie tentative d'intrusion dans ces attaques, mais elles nécessitent tout de même une alerte.

### Injection SQL

Les attaques par injection SQL consistent à remplir un champ avec une commande SQL afin d'en extraire des informations de la base de données, ou de valider une authentification. Nous avons décidé d'implémenter ces attaques car elles sont relativement simples à mettre en place même pour un attaquant débutant, et peuvent être dangereuses si le système n'est pas protégé contre.

### Bruteforce

Les attaques par bruteforce consistent à envoyer des tentatives répétées d'authentification à un certain endroit (ici un service SSH et un login web) afin de tenter de s'y introduire si les mots de passe sont trop simples. Nous avons implémenté ces attaques car elles peuvent encore une fois être facilement implémentées et se basent sur l'erreur humaine, ce qui leur donne des chances de succès plus hautes que des méthodes basées sur une faille logicielle, par exemple.

### Conteneur compromis

Ici, on va supposer qu'un attaquant ait déjà infiltré le système et ait pris possession d'un conteneur. Nous avons essayé avec ces scénarios de montrer ce qu'il se passait dans le cas où l'attaquant coupait tous les logs sortants du conteneur ou, au contraire, tentait d'inonder le reste des services avec des logs falsifiés et en grand nombre. Nous avons choisi d'implémenter cette attaque car elle nous permet de voir ce qu'il se serait passé dans le cas où les contre-mesures déjà mises en place en amont ne seraient pas suffisantes.

### Persistence

Enfin, nous avons choisi d'implémenter des attaques par persistence, qui supposent également que l'attaquant se soit déjà infiltré dans le système et qu'il décide de se créer des portes dérobées afin de pouvoir accéder au système à nouveau plus tard. Elles fonctionnent de deux façons différentes : l'attaquant ajoute sa clé SSH aux clés autorisées et ajoute un mécanisme de rappel automatique au démarrage du shell, ou l'attaquant ajoute un identifiant et mot de passe dans la base de données pour se reconnecter plus tard. Ces attaques nous semblaient pertinentes à ajouter car elles supposent à nouveau que les contre-mesures ajoutées en amont ne sont pas suffisantes, et nous montrent si on peut bien détecter un accès non autorisé qui aurait été ajouté à la main.
