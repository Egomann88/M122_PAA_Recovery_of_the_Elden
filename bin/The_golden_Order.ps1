<#
Projekt; Recovery of the elden
Letzte Änderung: 02.06.2022 11:34
Erstellt von: Dominic Tosku & Justin Urbanek
Version: 0.5
Versionsumschreibung: In der Testphase
#>

# -------------------------------------------------------------
# Gloable Variablen
# -------------------------------------------------------------
$date = Get-Date -Format "dd.MM.yyyy HH-mm-ss" # Akutelles Datum speichern
[string]$TopSrc = "C:\M122_PAA_Recovery_of_the_Elden\topSrc\" # Verzeichnis, vom dem ein Backup gemacht wird
[string]$TopBck = "C:\M122_PAA_Recovery_of_the_Elden\topBck\Backup $date\" # Verzeichnis indem die Files abgelegt werde
# [string]$BackupPath = $TopBck + "\*" # Wählt alle Dateien im Backup-Pfad aus

# -------------------------------------------------------------
# Wilkommensnachricht
# -------------------------------------------------------------
Write-host "Das Backup wird gestartet" -ForegroundColor Black -BackgroundColor white

# -------------------------------------------------------------
# Funktionen
# -------------------------------------------------------------

# Kopiert Elemente von Src und fügt diese in Bck ein
function CreateBackup {
  <# Diese Funktion nimmmt als Parameter zwei Pfade an #>
  Param(
    [string]$PathSrc = $TopSrc, # Pfad aus dem ein Backup erstellt werden soll / Default TopSrc
    [string]$PathBck = $TopBck # Pfad in welchem das Backup erstellt werden soll / Default TopBck
  )
  [string]$BackupFilesSrc = $PathSrc + "\*" # Objekt(e), das / die kopiert werden soll
  # Holt alle Elemnte im Src Verzeichnis
  Get-ChildItem -Path $BackupFilesSrc -Recurse  | ForEach-Object {
    [string]$targetFile = $PathBck + $_.FullName.SubString($PathSrc.Length); # Sorgt dafür das im Pfad die Überodner sind
    # Überprüft, ob das akutelle Element ein Ordner ist
    if ($_.PSIsContainer) {
      try {
        <# Versucht einen neuen Ordner zu erstellen #>
        New-Item -Path ($targetFile) -ItemType "directory" -Force | Out-Null
        Write-Host -ForegroundColor Green "Verzeichnis erfolgreich erstellt '$targetFile'."
      }
      catch {
        <# Der Ordner konnte nicht erstellt werden, evtl fehlen Schreibrechte.
           Ein Fehler wird ausgegeben #>
        Write-Error -Message "Ein Fehler beim erstellen von '$targetFile'. Fehler war: $_"
        Exit
      }
    }
    # Element ist ein File
    else {
      try {
        Copy-Item  -Path ($_.Fullname) -Destination ($targetFile) -Force -Container | Out-Null  # kopiert Element, ins Bck Verzeichnis
        Write-Host -ForegroundColor Green "Datei erfolgreich erstellt '$targetFile'."
      }
      catch {
        <# Die Datei konnte nicht erstellt werden, evtl fehlen Schreibrechte.
           Ein Fehler wird ausgegeben #>
        Write-Error -Message "Ein Fehler beim erstellen von '$targetFile'. Fehler war: $_"
      }
    }
  }
  Write-Host "Bitte warten Sie einen Moment, Prozesse laufen noch......." -ForegroundColor Yellow
  $result = controllBackup $PathSrc $PathBck # Ruft funktion zur Überprüfung auf und speichert Rückgabewert
  Write-Host $result[0] -BackgroundColor $result[1] -ForegroundColor Black #Gibt Resultat in Grün oder Rot an
}

# Zählt alle kopierten Objekte und ruft Funktion zum kontrollieren auf
function controllBackup([string]$checkSrc, [string]$checkBck) {
  # Zähler, wie viele Elemente kopiert werden sollen
  [int]$TotalSrcFiles = (Get-ChildItem $checkSrc -Recurse | Where-Object { !($_.PSIsContainer) }).Count
  # Zähler, wie viele Elemnte kopiert wurden
  [int]$TotalBckFiles = (Get-ChildItem $checkBck -Recurse | Where-Object { !($_.PSIsContainer) }).Count

  Write-Host "" # Zeilenumbruch
  Write-Host "Es wurden " $TotalBckFiles " Elemente von " $TotalSrcFiles " kopiert." # Info wie viele Files kopiert wurden
  Write-Host "Bitte warten Sie einen Moment, Prozesse laufen noch......." -ForegroundColor Yellow
  
  [boolean]$Korrekt = checkHash $checkSrc $checkBck # Ruft Funktion zum Hash check auf und speichert Ausgabe
  if ($Korrekt) {
    # Alle Elemente wurden kopiert
    return ("Das Backup war Erfolgreich", "Green") # Gibt String mit Farbe zurück
  }
  else {
    # Nicht alle Elemente wurden kopiert
    return ("Das Backup ist Fehlgeschlagen", "Red") # Gibt String mit Farbe zurück
  }
}
# !highlight meines Lebens –Path
# Kontrolliert den Hash des Source und Backup Ordners
function checkHash ([string]$Hash1, [string]$Hash2) {
  # Weisst den Hash aller Files im Source Ordner einer Variablen zu
  [string]$SrcHash = (Get-ChildItem -Path $Hash1 -Recurse | Where-Object { !($_.PSIsContainer) }) |
  ForEach-Object { (Get-FileHash -Path $_.FullName -a md5).Hash };
  # Weisst den Hash aller Files im Backup Ordner einer Variablen zu
  [string]$BackHash = (Get-ChildItem -Path $Hash2 -Recurse | Where-Object { !($_.PSIsContainer) }) |
  ForEach-Object { (Get-FileHash -Path $_.FullName -a md5).Hash };
  # Stimmt der Hash des Source und Backup Ordner überei?
  if ($SrcHash -eq $BackHash) {
    return 1 # Backup ist erfolgreich ausgeführt worden
  }
  else {
    Write-Host "Hashwerte des Quell- und Zielpfades stimmen nicht überein!" -ForegroundColor red
    return 0 # Backup ist fehlgeschlagen
  }
}

# Öffnet ein GUI mit Explorer zum Pfad Quel Pfad auswählen
Function Get-Folder($initialDirectory) {
  Add-Type -AssemblyName System.Windows.Forms
  [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  $FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
  $FolderBrowserDialog.RootFolder = 'MyComputer'
  if ($initialDirectory) { $FolderBrowserDialog.SelectedPath = $initialDirectory }
  [void] $FolderBrowserDialog.ShowDialog()
  return $FolderBrowserDialog.SelectedPath
}

# Erstellt eine Log File
# Informationen über alle Kopierten Dateien
function CreateLog {
  # Add-Content <File> -Value <LogText> # (Log-)Datei etwas anf�gen
}

# Shortcut für Clear-Host
# Cleart die Konsole
function cl {
  Clear-Host
}

# Letztes Ausführdatum in diesen Powershell-Skript wird überschrieben 
# ACHTUNG: Kann die Source File zerstören wenn das Regex nicht beachtet wird
function lastChangeDate() {
  Set-Location -path "C:\M122_PAA_Recovery_of_the_Elden\bin"
  # $Location = Get-Location
  [string]$file = "C:\M122_PAA_Recovery_of_the_Elden\bin\The_golden_Order.ps1" # die zu bearbeitende Datei 
  $txtFileContent = (Get-Content $file -raw); # Inhalt der Datei abspeichern
  [regex]$pattern = 'Letzte Änderung: \d\d.\d\d.\d\d\d\d \d\d:\d\d'; # sucht den Beriff "Letze Änderung"
  # Der Begriff "Letze Änderung" wird mit dem akutellen Datum ersetzt
  $pattern.Replace($txtFileContent, 'Letzte Änderung: ' + $date, 1) | Set-Content $file
}

# -------------------------------------------------------------
# Hauptcode
# -------------------------------------------------------------

# Logdatei erstellen
Start-Transcript "C:\M122_PAA_Recovery_of_the_Elden\log\Log_$date.txt"
CreateBackup # CreateBackup Funktion aufrufen
Stop-Transcript  #Log file abschliessen

Write-Host "Das Programm endet hier" -BackgroundColor White -ForegroundColor Black