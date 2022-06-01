<#
Projekt; Recovery of the elden
Letzte �nderung: 01.06.2022 11:16
Erstellt von: Dominic Tosku & Justin Urbanek
Version: 0.5
Versionsumschreibung: In der Testphase
#>


# ----
# Gloable Variablen
# ----
$TopSrc = "C:\Users\KIM\Documents\Beruffsschule\Pap Partnerarbeit\M122_PAA_Recovery_of_the_Elden\topSrc" # Verzeichnis, vom dem ein Backup gemacht wird
$TopBck = "C:\Users\KIM\Documents\Beruffsschule\Pap Partnerarbeit\M122_PAA_Recovery_of_the_Elden\topBck" # Verzeichnis indem die Files abgelegt werden
$date = Get-Date -Format "dd.MM.yyyy HH:mm" # Akutelles Datum speichern
$TotalBackupedFilles = 0 # Z�hler, wie viele Dateien insegesamt kopiert wurden

# ---------------------------------------------------------------------------------
# regex scheisse
# ---------------------------------------------------------------------------------
function lastChangeDate() {
  Set-Location -path "C:\Users\KIM\Documents\Beruffsschule\Pap Partnerarbeit\M122_PAA_Recovery_of_the_Elden\bin"
  $Location = Get-Location
  $file = "C:\Users\KIM\Documents\Beruffsschule\Pap Partnerarbeit\M122_PAA_Recovery_of_the_Elden\bin\Jo.txt"
  $regex = 'Letzte �nderung: [^"]*' # um die Letzte �nderung zu finden
  # Der Begriff "Letze �nderung" wird mit dem akutellen Datum ersetzt
    (Get-Content $file) -replace $regex, ('Letzte �nderung: ' + $date) | Set-Content $file
}


# ---------------------------------------------------------------------------------
# Backup
# ---------------------------------------------------------------------------------

# Logdatei erstellen

Start-Transcript C:\M122_PAA_Recovery_of_the_Elden\log\Log_$date.txt



# ----
# Einfaches Kopieren
$BackupFilesSrc = $TopSrc + "\*" # Objekt(e), das / die kopiert werden soll
$BackupPath = $TopBck + "\*" # W�hlt alle Dateien im Backup-Pfad aus


$TotalBackupedFilles = (Get-ChildItem -Recurse | Measure-Object).Count

# Erstellt das Backup der jeweiligen Datein in TopBck //// Testversion
  Get-ChildItem -Path $BackupFilesSrc -Recurse | ForEach-Object {
    <#   $_.Name #>
    Copy-Item  -Path $_ -Destination $TopBck
  }

# Erstellt das Backup der jeweiligen Datein in TopBck //// Finale Version
function doBackup() {
  # Komplett unbrauchbar
  Copy-Item -Path $BackupFilesSrc -Destination $TopBck -Force # Dateien kopieren
  Get-ChildItem -Recurse # �berpr�fen ob Objekt kopiert wird
  Write-Host "" # Zeilenumbruch
  Write-Host "Insgesamt wurden " $TotalBackupedFilles " Dateien kopiert" # Information, wie viele Dateien kopiert wurden
  
}

Stop-Transcript # Log file abschliessen

# ----
function cl {
  Clear-Host
}

function CreateLog {
    
  # Add-Content <File> -Value <LogText> # (Log-)Datei etwas anf�gen
}

function CreateBackup {

}
