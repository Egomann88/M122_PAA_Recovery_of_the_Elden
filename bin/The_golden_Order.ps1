<#
Projekt; Recovery of the elden
Letzte Änderung: 02.06.2022 11:34
Erstellt von: Dominic Tosku & Justin Urbanek
Version: 0.5
Versionsumschreibung: In der Testphase
#>
 Write-host $whatisit -ForegroundColor Black -BackgroundColor white
# ----
# Gloable Variablen
# ----
$TopSrc = "C:\M122_PAA_Recovery_of_the_Elden\topSrc\" # Verzeichnis, vom dem ein Backup gemacht wird
$TopBck = "C:\M122_PAA_Recovery_of_the_Elden\topBck\" # Verzeichnis indem die Files abgelegt werden
$date = Get-Date -Format "dd.MM.yyyy HH:mm:ss" # Akutelles Datum speichern
$BackupFilesSrc = $TopSrc + "\*" # Objekt(e), das / die kopiert werden soll
$BackupPath = $TopBck + "\*" # Wählt alle Dateien im Backup-Pfad aus

# ---------------------------------------------------------------------------------
# * Backup Funktionen
# ---------------------------------------------------------------------------------
function CreateBackup() {
  Get-ChildItem -Path $BackupFilesSrc -Recurse  | ForEach-Object {
    $targetFile = $TopBck + $_.FullName.SubString($TopSrc.Length);
    if ($_.PSIsContainer) {
      New-Item -Path ($targetFile) -ItemType "directory" -Force
      <# Copy-Item  -Path ($TopSrc + $_) -Recurse -Destination ($TopBck + $_) -Force #> # ! Leftover Code
    }
    else {
      Copy-Item  -Path ($_.Fullname) -Destination ($targetFile ) -Force -Container
    }
  }
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

function deleteThis {
  $Happy = "Dieses Program wird funktionieren";
  $Sad = "Dieses Program wird nicht funktionieren";
  $whatisit = ""
  if ((Get-Random -Minimum 0 -Maximum 3) -eq 1) {
    $whatisit = $Happy;
  }
  else {
    $whatisit = $Sad;
  }
}

# Logdatei erstellen
Start-Transcript C:\M122_PAA_Recovery_of_the_Elden\log\Log_$date.txt
CreateBackup
# ----
# * Erstellt das Backup der jeweiligen Datein in TopBck
# ----
# Zähler, wie viele Dateien kopiert werden sollen
# * Zeigt an ob alle Dateien erfolgreich Kopiert wurden
$TotalSrcFiles = (Get-ChildItem $TopSrc -Recurse | Where-Object { !($_.PSIsContainer) }).Count
$TotalBckFiles = (Get-ChildItem $TopBck -Recurse | Where-Object { !($_.PSIsContainer) }).Count

# nach dem Backup prüfen, ob alle Files kopiert wurden
$TotalBckFiles = (Get-ChildItem $TopBck -Recurse | Where-Object { !($_.PSIsContainer) }).Count
Write-Host "" # Zeilenumbruch
Write-Host "Es wurden " $TotalBckFiles " Elemente von " $TotalSrcFiles " kopiert." # Info wie viele Files kopiert wurden
if ($TotalSrcFiles -ne $TotalBckFiles) {
  Write-Host "Das Backup ist Fehlgeschlagen" -BackgroundColor Red -ForegroundColor Black
}
else {
  Write-Host "Das Backup war Erfolgreich" -BackgroundColor Green -ForegroundColor Black
}

Stop-Transcript  #Log file abschliessen

