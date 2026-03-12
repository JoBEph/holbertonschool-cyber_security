# Laboratoire d'Escalade de Privilèges : Fichiers Windows Unattended

## Vue d'Ensemble du Projet

Ce laboratoire démontre une technique courante d'escalade de privilèges sur Windows. Il consiste à localiser des fichiers d'installation automatisée (Unattend.xml), extraire des identifiants administratifs encodés à l'aide de Python/Regex, et établir une session administrative pour récupérer un flag cible.

---

## Étape 1 : Configuration de la Machine Virtuelle (Dépannage)

Initialement, la VM n'a pas pu démarrer avec l'erreur `Could not read from the boot medium`.

**Correction :**
- Extraction complète de l'archive `.zip` dans un dossier local
- Import via `File > Import Appliance` dans VirtualBox pour lier correctement le `.ovf` et le disque virtuel `.vmdk`
- Validation des paramètres du contrôleur de stockage pour s'assurer que le disque était correctement attaché

---

## Étape 2 : Reconnaissance & Localisation des Fichiers

Numérisation du système pour trouver les emplacements communs des fichiers d'installation sensibles.

**Commande utilisée :**
```cmd
dir /s C:\unattend.xml C:\autounattend.xml C:\sysprep.inf
```

**Résultat :** Fichier valide trouvé à `C:\Windows\Panther\Unattend.xml`

---

## Étape 3 : Extraction & Décodage du Mot de Passe

Le fichier contenait un bloc `<AdministratorPassword>` avec une valeur encodée.

**Chaîne Extraite :** `U3VwM2VyU2VjcmV0UGFzczRBRG0xbg`

**Méthode :**
- Utilisation d'un script Python avec des expressions régulières (Regex) pour isoler la balise `<Value>`
- La chaîne étant encodée en Base64, décodage avec `certutil` (CMD) ou `base64` (Python)

**Mot de Passe Final :** `Sup3erSecretPass4ADm1n`

---

## Étape 4 : Escalade de Privilèges (Runas)

L'utilisateur administratif cible a été identifié comme `SuperAdministrator`. Nous avons utilisé la commande `runas` pour pivoter vers une session élevée.

**Commande :**
```cmd
runas /user:SuperAdministrator "cmd.exe /k C:\Users\SuperAdministrator\Desktop\flag.exe"
```

**Exécution :**
- Saisie du mot de passe décodé lorsque demandé
- Exécution du programme flag.exe pour récupérer le flag

---

## Étape 5 : Script Automatisé (extract_password.py)

Le script `extract_password.py` automatise le processus de découverte, d'extraction et de décodage :

### Fonctionnalités du Script

1. **Numérisation des emplacements** : Recherche automatique dans les chemins communs
   - `C:\Windows\Panther`
   - `C:\Windows\System32\sysprep`
   - `C:\`

2. **Extraction avec Regex** : Isolation de la valeur dans la balise `<AdministratorPassword>`

3. **Décodage Base64** : Conversion automatique de la valeur encodée

4. **Instructions finales** : Affichage de la commande `runas` à exécuter avec le mot de passe décodé

### Exécution du Script

```bash
python3 extract_password.py
```

**Sortie attendue :**
```
[*] Searching for unattended files...
[+] Found: C:\Windows\Panther\Unattend.xml
[*] Extracted Value: U3VwM2VyU2VjcmV0UGFzczRBRG0xbg
[+] Decoded Password: Sup3erSecretPass4ADm1n

==============================
FINAL STEP: ESTABLISH ADMIN SESSION
==============================
Run this command in CMD:
runas /user:SuperAdministrator "C:\Users\SuperAdministrator\Desktop\flag.exe"

Password to type: Sup3erSecretPass4ADm1n
==============================
```

---

## Conclusion Task 0

Le laboratoire a été complété avec succès en exploitant des identifiants stockés de manière non sécurisée dans les fichiers de configuration Windows. Le flag final a été récupéré en exécutant `flag.exe` en tant que `SuperAdministrator`.

### Leçons Apprises

- Les fichiers d'installation automatisée peuvent contenir des informations sensibles
- L'encodage Base64 n'est pas une méthode de chiffrement sécurisée
- La commande `runas` permet l'exécution de programmes avec des privilèges différents
- Les expressions régulières sont efficaces pour extraire des données structurées

---

# TASK 1 : Privilege Escalation via SAM & SYSTEM Backup Files

## Objectif

Exploiter une vulnérabilité du système pour récupérer le mot de passe du compte `superAdministrator` et récupérer le flag.

**VM Cible :** LAB02  
**Compte utilisé :** Sammy  
**Mot de passe Sammy :** Sammy

---

## Étape 1 : Énumération des Privilèges

Télécharger et exécuter le script PowerShell **PrivCheck** sur le système cible pour identifier les vulnérabilités.

**Analyse de la sortie :**
- Identifier la vulnérabilité liée aux fichiers de sauvegarde SAM et SYSTEM
- Repérer les chemins d'accès aux fichiers sensibles

---

## Étape 2 : Recherche et Exploitation

**Recherche :**
- Rechercher en ligne la vulnérabilité identifiée
- Localiser et télécharger un exploit fonctionnel (fichier `.exe`)

**Exploitation :**
- Utiliser l'exploit pour extraire les fichiers critiques du système cible (SAM et SYSTEM)

---

## Étape 3 : Extraction des Hashes

**Sur Kali Linux :**

1. S'assurer que le toolkit **Impacket** est installé
2. Utiliser l'outil `secretsdump.py` pour extraire les hashes de mots de passe à partir des fichiers SAM et SYSTEM

**Commande exemple :**
```bash
secretsdump.py -sam SAM -system SYSTEM LOCAL
```

---

## Étape 4 : Accès Session Administrateur

**Méthode PowerShell avec Credentials :**

Utiliser PowerShell pour exécuter des commandes en tant que `superAdministrator` et copier les fichiers protégés vers un emplacement accessible.

```powershell
$password = ConvertTo-SecureString "P@ssword" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("superAdministrator", $password)
Start-Process "cmd.exe" -ArgumentList "/c copy C:\Users\superAdministrator\Desktop\* C:\Users\Public\" -Credential $cred
Start-Sleep -s 2
ls C:\Users\Public\
```

**Récupération du flag :**
- Ouvrir une session administrateur en utilisant les hashes récupérés
- Localiser et récupérer le flag
- Sauvegarder le flag dans `1-flag.txt`

---

## Conclusion Task 1

L'exploitation des fichiers de sauvegarde SAM et SYSTEM permet d'extraire les hashes de mots de passe et d'obtenir un accès administrateur. Cette technique démontre l'importance de protéger les fichiers système sensibles.

### Leçons Apprises

- Les fichiers SAM et SYSTEM contiennent des informations critiques pour l'authentification Windows
- L'outil `secretsdump.py` d'Impacket est efficace pour extraire les hashes
- PowerShell permet d'exécuter des commandes avec des credentials spécifiques
- Les fichiers de sauvegarde non protégés représentent un risque de sécurité majeur
