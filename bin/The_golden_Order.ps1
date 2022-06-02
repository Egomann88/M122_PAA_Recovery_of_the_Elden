<#
Projekt; Recovery of the elden
Letzte Änderung: 02.06.2022 09:21
Erstellt von: Dominic Tosku & Justin Urbanek
Version: 0.5
Versionsumschreibung: In der Testphase
#>


# ----
# Gloable Variablen
# ----
$TopSrc = "C:\M122_PAA_Recovery_of_the_Elden\topSrc" # Verzeichnis, vom dem ein Backup gemacht wird
$TopBck = "C:\M122_PAA_Recovery_of_the_Elden\topBck" # Verzeichnis indem die Files abgelegt werden
$date = Get-Date -Format "dd.MM.yyyy HH:mm" # Akutelles Datum speichern
$TotalBackupedFilles = 0 # Zähler, wie viele Dateien insegesamt kopiert wurden

# ---------------------------------------------------------------------------------
# * Backup Funktionen
# ---------------------------------------------------------------------------------

# Logdatei erstellen
# todo: Sollte ersetzt werden, da zu viel im Log steht
Start-Transcript C:\M122_PAA_Recovery_of_the_Elden\log\Log_$date.txt

# ----
# Einfaches Kopieren
# ? Könnte anders gelöst werden
$BackupFilesSrc = $TopSrc + "\*" # Objekt(e), das / die kopiert werden soll
$BackupPath = $TopBck + "\*" # Wählt alle Dateien im Backup-Pfad aus

# Zählt alle Dateien im Backup Ordner
# * Zeigt an ob alle Dateien erfolgreich Kopiert wurden
$TotalBackupedFilles = (Get-ChildItem -Recurse | Measure-Object).Count

# ! Erstellt das Backup der jeweiligen Datein in TopBck //// Testversion
Get-ChildItem -Path $BackupFilesSrc -Recurse | ForEach-Object {
  <#   $_.Name #>
  Copy-Item  -Path $_ -Destination $TopBck
}

# ----
# * Erstellt das Backup der jeweiligen Datein in TopBck //// Finale Version
# ----
function CreateBackup() {
  # ? Komplett unbrauchbar
  Copy-Item -Path $BackupFilesSrc -Destination $TopBck -Force # Dateien kopieren
  Get-ChildItem -Recurse # Überprüfen ob Objekt kopiert wird
  Write-Host "" # Zeilenumbruch
  Write-Host "Insgesamt wurden " $TotalBackupedFilles " Dateien kopiert" # Information, wie viele Dateien kopiert wurden
  
}

Stop-Transcript # Log file abschliessen

# ---------------------------------------------------------------------------------
# * Sekundäre Funktionen
# ---------------------------------------------------------------------------------

# ----
# * regex :( . Letztes Änderungsdatum wird überschrieben in diesen Powershell Skript
# ! Kann die Source File zerstören, mit vorsicht geniessen
# ----
function lastChangeDate() {
  Set-Location -path "C:\M122_PAA_Recovery_of_the_Elden\bin"
  $Location = Get-Location
  $file = "C:\M122_PAA_Recovery_of_the_Elden\bin\The_golden_Order.ps1"
  $txtFileContent = (Get-Content $file -raw);
  [regex]$pattern = 'Letzte Änderung: \d\d.\d\d.\d\d\d\d \d\d:\d\d'; # um die Letzte Änderung zu finden
  # Der Begriff "Letze Änderung" wird mit dem akutellen Datum ersetzt
  $pattern.Replace($txtFileContent, 'Letzte Änderung: ' + $date, 1) | Set-Content $file
}

lastChangeDate

# * Säubert die Konsole
function cl {
  Clear-Host
}
# * Erstellt ein Log File und zeigt die kopierten Dateien
# * Zeigt Status des erfolgreichen Abschliessens an
function CreateLog {
  # Add-Content <File> -Value <LogText> # (Log-)Datei etwas anf�gen
}

