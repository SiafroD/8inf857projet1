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
