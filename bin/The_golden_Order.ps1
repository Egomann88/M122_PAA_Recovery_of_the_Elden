<#
Projekt; Recovery of the elden
Letzte Änderung: 02.06.2022 11:34
Erstellt von: Dominic Tosku & Justin Urbanek
Version: 0.5
Versionsumschreibung: In der Testphase
#>


$Happy = "Dieses Program wird funktionieren";
$Sad = "Dieses Program wird nicht funktionieren";
$whatisit = ""
if ((Get-Random -Minimum 0 -Maximum 3) -eq 1) {
  $whatisit = $Happy;
}
else {
  $whatisit = $Sad;
}

Write-host $whatisit -ForegroundColor Black -BackgroundColor white

# ----
# Gloable Variablen
# ----
$TopSrc = "C:\M122_PAA_Recovery_of_the_Elden\topSrc\" # Verzeichnis, vom dem ein Backup gemacht wird
$TopBck = "C:\M122_PAA_Recovery_of_the_Elden\topBck\" # Verzeichnis indem die Files abgelegt werden
$date = Get-Date -Format "dd.MM.yyyy HH:mm:ss" # Akutelles Datum speichern

# ---------------------------------------------------------------------------------
# * Backup Funktionen
# ---------------------------------------------------------------------------------

# Logdatei erstellen
# todo: Sollte ersetzt werden, da zu viel im Log steht
# Start-Transcript C:\M122_PAA_Recovery_of_the_Elden\log\Log_$date.txt

# ----
# Einfaches Kopieren
# ? Könnte anders gelöst werden
$BackupFilesSrc = $TopSrc + "\*" # Objekt(e), das / die kopiert werden soll
$BackupPath = $TopBck + "\*" # Wählt alle Dateien im Backup-Pfad aus

# Zähler, wie viele Dateien kopiert werden sollen
# * Zeigt an ob alle Dateien erfolgreich Kopiert wurden
$TotalSrcFiles = (Get-ChildItem $TopSrc -Recurse | Where-Object { !($_.PSIsContainer) }).Count
$TotalBckFiles = (Get-ChildItem $TopBck -Recurse | Where-Object { !($_.PSIsContainer) }).Count

# ! Erstellt das Backup der jeweiligen Datein in TopBck //// Testversion
Get-ChildItem -Path $BackupFilesSrc -Recurse  | ForEach-Object {

  if ($_.PSIsContainer) {
    New-Item -Path ($TopBck + $_.Name) -ItemType "directory"
    <#  Copy-Item  -Path ($TopSrc + $_) -Recurse -Destination ($TopBck + $_) -Force  #>
  }
  else {
    Copy-Item  -Path ($_.Fullname) -Destination ($TopBck + $_.Parent + '\' + $_) -Force
  }
}

<# for ($shit = 0; $shit -lt 2; $shit++) {

  $shitshit = Get-ChildItem -Path $BackupFilesSrc 
  Copy-Item  -Path $shitshit -Destination $TopBck -Force -Recurse
} #>

# nach dem Bck prüfen, ob alle Files kopiert wurden
$TotalBckFiles = (Get-ChildItem $TopBck -Recurse | Where-Object { !($_.PSIsContainer) }).Count
Write-Host "" # Zeilenumbruch
Write-Host "Es wurden " $TotalBckFiles " Elemente von " $TotalSrcFiles " kopiert." # Info wie viele Files kopiert wurden
if ($TotalSrcFiles -ne $TotalBckFiles) {
  Write-Host "Das Backup ist Fehlgeschlagen" -BackgroundColor Red -ForegroundColor Black
}
else {
  Write-Host "Das Backup war Erfolgreich" -BackgroundColor Green -ForegroundColor Black
}

# Stop-Transcript  Log file abschliessen



# ----
# * Erstellt das Backup der jeweiligen Datein in TopBck //// Finale Version
# ----
function CreateBackup() {
  # ? Komplett unbrauchbar
  Copy-Item -Path $BackupFilesSrc -Destination $TopBck -Force # Dateien kopieren
  Get-ChildItem -Recurse # Überprüfen ob Objekt kopiert wird
  
}

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


# * Säubert die Konsole
function cl {
  Clear-Host
}
# * Erstellt ein Log File und zeigt die kopierten Dateien
# * Zeigt Status des erfolgreichen Abschliessens an
function CreateLog {
  # Add-Content <File> -Value <LogText> # (Log-)Datei etwas anf�gen
}