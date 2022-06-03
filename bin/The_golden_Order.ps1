<#
Projekt; Recovery of the elden
Letzte Änderung: 02.06.2022 11:34
Erstellt von: Dominic Tosku & Justin Urbanek
Version: 0.5
Versionsumschreibung: In der Testphase
#>

# ----
# Gloable Variablen
# ----
$date = Get-Date -Format "dd.MM.yyyy HH-mm-ss" # Akutelles Datum speichern
[string]$TopSrc = "C:\M122_PAA_Recovery_of_the_Elden\topSrc\" # Verzeichnis, vom dem ein Backup gemacht wird
[string]$TopBck = "C:\M122_PAA_Recovery_of_the_Elden\topBck\Backup $date\" # Verzeichnis indem die Files abgelegt werden
[string]$BackupFilesSrc = $TopSrc + "\*" # Objekt(e), das / die kopiert werden soll
# [string]$BackupPath = $TopBck + "\*" # Wählt alle Dateien im Backup-Pfad aus

# ----
# Wilkommensnachricht
# ----
Write-host "Das Backup wird gestartet" -ForegroundColor Black -BackgroundColor white

# ----
# Funktionen
# ----

# Kopiert Elemente von Src und fügt diese in Bck ein
function CreateBackup() {
  # Holt alle Elemnte im Src Verzeichnis
  Get-ChildItem -Path $BackupFilesSrc -Recurse  | ForEach-Object {
    [string]$targetFile = $TopBck + $_.FullName.SubString($TopSrc.Length); # Pfad mit den Überordnern
    # Überprüft, ob das akutelle Element ein Ordner ist
    if ($_.PSIsContainer) {
      New-Item -Path ($targetFile) -ItemType "directory" -Force # Neuen Ordner erstellen
    }
    else {
      Copy-Item  -Path ($_.Fullname) -Destination ($targetFile) -Force -Container # kopiert Element, ins Bck Verzeichnis  
    }
  }
}

# Letztes Änderungsdatum in diesen Powershell-Skript wird überschrieben 
# ACHTUNG: Kann die Source File zerstören
function lastChangeDate() {
  Set-Location -path "C:\M122_PAA_Recovery_of_the_Elden\bin"
  # $Location = Get-Location
  [string]$file = "C:\M122_PAA_Recovery_of_the_Elden\bin\The_golden_Order.ps1" # die zu bearbeitende Datei 
  $txtFileContent = (Get-Content $file -raw); # Inhalt der Datei abspeichern
  [regex]$pattern = 'Letzte Änderung: \d\d.\d\d.\d\d\d\d \d\d:\d\d'; # sucht den Beriff "Letze Änderung"
  # Der Begriff "Letze Änderung" wird mit dem akutellen Datum ersetzt
  $pattern.Replace($txtFileContent, 'Letzte Änderung: ' + $date, 1) | Set-Content $file
}

# Shortcut für Clear-Host
# Cleart die Konsole
function cl {
  Clear-Host
}

# Erstellt eine Log File
# Informationen über alle Kopierten Dateien
function CreateLog {
  # Add-Content <File> -Value <LogText> # (Log-)Datei etwas anf�gen
}

# ----
# Hauptcode
# ----

# Logdatei erstellen
Start-Transcript C:\M122_PAA_Recovery_of_the_Elden\log\Log_$date.txt
CreateBackup # CreateBackup Funktion aufrufen


# Zähler, wie viele Elemente kopiert werden sollen
[int]$TotalSrcFiles = (Get-ChildItem $TopSrc -Recurse | Where-Object { !($_.PSIsContainer) }).Count
# Zähler, wie viele Elemnte kopiert wurden
[int]$TotalBckFiles = (Get-ChildItem $TopBck -Recurse | Where-Object { !($_.PSIsContainer) }).Count

Write-Host "" # Zeilenumbruch
Write-Host "Es wurden " $TotalBckFiles " Elemente von " $TotalSrcFiles " kopiert." # Info wie viele Files kopiert wurden
if ($TotalSrcFiles -eq $TotalBckFiles) {
  # Alle Elemente wurden kopiert
  Write-Host "Das Backup war Erfolgreich" -BackgroundColor Green -ForegroundColor Black
}
else {
  # Nicht alle Elemente wurden kopiert
  Write-Host "Das Backup ist Fehlgeschlagen" -BackgroundColor Red -ForegroundColor Black
}

Stop-Transcript  #Log file abschliessen

Write-Host "Das Programm endet hier" -BackgroundColor White -ForegroundColor Black