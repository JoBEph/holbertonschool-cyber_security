**Report Web Application Forensic**

**Introduction :**

Analyser les logs d'une application Web est essentiel pour identifier et comprendre les attaques. Afin de pouvoir augmenter les défenses.

 La collecte, la préservation et l’analyse des preuves numériques comme le trafic réseau et les journaux HTTP. Les organisations peuvent ainsi détecter les anomalies, reconstituer les incidents et mettre en œuvre des stratégies de protection conformes aux normes juridiques (RGPD).

**Draft an Incident Report :**

L’Analyse des logs révèle une importante faille du service d’authentification (SSH). et des comptes système.

Plusieurs attaquants non autorisés ont accédé au système, principalement via le compte Kayn, qui ensuite été utilisé pour une élévation des privilèges jusqu’à l’administrateur (root). Celà à permis aux attaquants de manipuler les configuration système comme les règles du pare-feu et les comptes utilisateurs.

**Le compte compromis :**

*   Kayn.
    
*   Tentative de connexion multiple suivie d’un accès autorisé.
    
*   Le hacker augmente les privilèges au root après la connexion.
    

**Le nombre d’attaques :**

*   18 attaques distinctes basés par IP unique.
    
*   indique un partage multiple d’identifiant ou de robots automatisés.
    

**Modification non autorisées des règles Firewall :**

*   L’analyse du fichier texte auth.log à détecter plusieurs entrées modifiant les règles du pare-feu.
    
*   Nombre de règles non autorisés ajouté : 6
    

**Nombre d’utilisateurs créés :**

*   Plusieurs utilisateurs sont créés suite à cet incident.
    
*   Aphelios, Debian-exim, Fido, Jax, Nidalee, Senna, dhg, messagebus, mysql, packet, sshd.
    
*    Debian-exim, Fido, dhg, messagebus, mysql, packet, sshd peuvent être liées au système.
    
*   Aphelios, Jax, Nidalee, Senna ont été créés manuellement.
    

**Impact Assessment**

**Confidentialité :**

*   L’accès Root est compromis.
    
*   Exfiltration possible des données, identifiants…
    

**Intégrité :**

*   Comptes utilisateurs créer et supprimer.
    
*   Règles de Firewall modifiées.
    
*   Risque élevé de mécanismes de persistance cachés.
    

**Disponibilité :**

*   Aucune attaque par déni de service direct n’a été observée, mais le système est resté sous contrôle de l’attaquant pendant des périodes prolongées.
    

**Timeline des Incidents**

**auth.log :**

Mai 16 08:12:04 app-1 login\[4659\]: pam\_unix(login:session): session opened for user Kayn by LOGIN(uid=0)

Mai 16 08:12:09 app-1 sudo:     Kayn : TTY=tty1 ; PWD=/home/Kayn ; USER=root ; COMMAND=/bin/su

Mai 16 08:12:09 app-1 sudo: pam\_unix(sudo:session): session opened for user root by Kayn(uid=0)

Mai 16 08:12:09 app-1 sudo: pam\_unix(sudo:session): session closed for user root

Mai 16 08:12:09 app-1 su\[4679\]: Successful su for root by root

Mai 16 08:12:09 app-1 su\[4679\]: + tty1 root:root

Mai 16 08:12:09 app-1 su\[4679\]: pam\_unix(su:session): session opened for user root by Kayn(uid=0)

Mai 16 08:12:13 app-1 groupadd\[4691\]: new group: name=Nidalee, GID=1001

Mai 16 08:12:13 app-1 useradd\[4692\]: new user: name=Nidalee, UID=1001, GID=1001, home=/home/Nidalee, shell=/bin/bash

Mai 16 08:12:17 app-1 passwd\[4695\]: pam\_unix(passwd:chauthtok): password changed for Nidalee

Mai 16 08:12:22 app-1 chfn\[4696\]: changed user \`Nidalee' information

Mai 16 08:12:31 app-1 userdel\[4700\]: delete user \`Nidalee' 

Mai 16 08:12:31 app-1 userdel\[4700\]: removed group \`Nidalee' owned by \`Nidalee' 

Mai 16 08:12:38 app-1 groupadd\[4702\]: new group: name=Jax, GID=1001

Mai 16 08:12:38 app-1 useradd\[4703\]: new user: name=Jax, UID=1001, GID=1001, home=/home/Jax, shell=/bin/bash

Mai 16 08:12:44 app-1 passwd\[4706\]: pam\_unix(passwd:chauthtok): password changed for Jax

Mai 16 08:12:46 app-1 chfn\[4707\]: changed user \`Jax' information

Mai 16 08:12:49 app-1 chfn\[4708\]: changed user \`Jax' information

Mai 16 08:12:55 app-1 groupadd\[4710\]: new group: name=Aphelios, GID=1002

Mai 16 08:12:55 app-1 useradd\[4711\]: new user: name=Aphelios, UID=1002, GID=1002, home=/home/Aphelios,

…

**Conclusion :**

Le serveur web a été compromis via une faille SSH. Le compte Kayn a permis une élévation de privilèges root, la création de comptes non autorisés et la modification des règles du pare-feu. 18 attaques distinctes ont été détectées et 6 règles firewall ajoutées pour maintenir un accès persistant. 

**Recommandation & Future mitigations :**

*   Confinement : Isolation du système.
    
*   Eradication : Suppression des comptes non autorisés, et la restauration des règles Firewall.
    
*   Reconstruction : Mise à jour des paquets, renforcer l'authentification (MFA).
    
*   Prévention : Mettre en place un IDS/IPS pour une surveillance constante des logs.
    
*   Définir un monitoring protocolaire journalier et alerte automatique.
