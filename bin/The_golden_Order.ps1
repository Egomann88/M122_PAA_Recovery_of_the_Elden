<#


#>

# ----
# Globale Variablen erstellen ^
# ----
$TopSrc = "C:\M122_PAA_Recovery_of_the_Elden-main\topSrc\" # Verzeichnis, vom dem ein Backup gemacht wird
$TopBck = "C:\M122_PAA_Recovery_of_the_Elden-main\topBck\" # Indem die Files abgelegt werden
$date = Get-Date -Format "yyyy-MM-dd HH-mm-ss" # Akutelles Datum speichern
$TotalBackupedFilles = 0 # Zähler, wie viele Dateien insegesamt kopiert wurden

# Logdatei erstellen
Start-Transcript C:\M122_PAA_Recovery_of_the_Elden-main\log\Log_$date.txt

# ----
# Einfaches Kopieren
$BackupFilesSrc = $TopSrc + "\*" # Objekt(e), das / die kopiert werden soll
$BackupPath = $TopBck + "\*" # Wählt alle Dateien im Backup-Pfad aus


$TotalBackupedFilles = (Get-ChildItem -Recurse | Measure-Object).Count

Get-ChildItem -Path $BackupFilesSrc -Recurse | foreach {
    Write-Host "oiafhwaihfahfoawhfoahofhfoawhfowahfoiawhfoawhfoawhfahfowahfohawfo"
    $_.Parent
    Write-Host "dhawodhahohawofhawofhwaofhoWAHFOhofahiofhawiof1"
    # Copy-Item  -Path $_.Name -Destination $TopBck
}

# Copy-Item -Path $BackupFilesSrc -Destination $TopBck -Force # Dateien kopieren

# Get-ChildItem -Recurse # überprüfen ob Objekt kopiert wird

Write-Host "" # Zeilenumbruch
Write-Host "Insgesamt wurden " $TotalBackupedFilles " Dateien kopiert" # Information, wie viele Dateien kopiert wurden

Stop-Transcript # Log file abschliessen

# ----
function cl {
    clear
}

function CreateLog {
    
    # Add-Content <File> -Value <LogText> # (Log-)Datei etwas anfügen
}

function CreateBackup {

}