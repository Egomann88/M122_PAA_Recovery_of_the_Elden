<#
Projekt; Recovery of the elden
Letzte Änderung: 16.06.2022 11:34
Erstellt von: Dominic Tosku & Justin Urbanek
Version: 1.0
Versionsumschreibung: Funktionstüchtig und Release bereit
#>

# -------------------------------------------------------------
# Gloable Variablen
# -------------------------------------------------------------
$date = Get-Date -Format "dd.MM.yyyy HH-mm-ss" # Akutelles Datum speichern
[string]$TopSrc = "C:\M122_PAA_Recovery_of_the_Elden\topSrc\" # Verzeichnis, vom dem ein Backup gemacht wird
[string]$TopBck = "C:\M122_PAA_Recovery_of_the_Elden\topBck\Backup $date\" # Verzeichnis indem die Files abgelegt werde
[string]$TopLog = "C:\M122_PAA_Recovery_of_the_Elden\log\Log_$date.txt"
$Global:userMail = "" # Mail des Nutzers
$Global:BckSucces = "" # Endnachricht für Email


# Pfad des Skripts wird dem Powershell skript Standort zugewiesen
# Powershell hat ein Problem mit relativen Pfaden, in Visual Studio Code kann dies ignoriert werden
Set-Location $PSScriptRoot


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
  CreateLog 1 # Startet die Log File
  [string]$BackupFilesSrc = $PathSrc # Objekt(e), das / die kopiert werden soll
  # Holt alle Elemnte im Src Verzeichnis
  New-Item -Path ($PathBck) -ItemType "directory" -Force | Out-Null # Erstellt das Oberste Verzeichnis des Backup Ordners
  Get-ChildItem -Path $BackupFilesSrc -Recurse  | ForEach-Object {
    [string]$targetFile = $PathBck + $_.FullName.SubString($PathSrc.Length); # Sorgt dafür das im Pfad die Überodner sind
    # Überprüft, ob das akutelle Element ein Ordner ist
    if ($_.PSIsContainer) {
      try {
        # Versucht einen neuen Ordner zu erstellen
        New-Item -Path ($targetFile) -ItemType "directory" -Force | Out-Null
        Write-Host -ForegroundColor Green "Verzeichnis erfolgreich erstellt '$targetFile'."
        Write-Output "Verzeichnis erfolgreich erstellt '$targetFile'." | Out-file $TopLog -Append
      }
      catch {
        # Der Ordner konnte nicht erstellt werden, evtl fehlen Schreibrechte.
        # Ein Fehler wird ausgegeben
        Write-Error -Message "Ein Fehler beim erstellen von '$targetFile'. Fehler war: $_"
        Write-Output "Ein Fehler beim erstellen von '$targetFile'. Fehler war: $_" | Out-file $TopLog -Append
        Exit
      }
    }
    # Element ist ein File
    else {
      try {
        Copy-Item  -Path ($_.Fullname) -Destination ($targetFile) -Force -Container | Out-Null  # kopiert Element, ins Bck Verzeichnis
        Write-Host -ForegroundColor Green "Datei erfolgreich erstellt '$targetFile'."
        Write-Output "Datei erfolgreich erstellt '$targetFile'." | Out-file $TopLog -Append
      }
      catch {
        # Die Datei konnte nicht erstellt werden, evtl fehlen Schreibrechte.
        # Ein Fehler wird ausgegeben
        Write-Error -Message "Ein Fehler beim erstellen von '$targetFile'. Fehler war: $_"
        Write-Output "Ein Fehler beim erstellen von '$targetFile'. Fehler war: $_" | Out-file $TopLog -Append
      }
    }
  }
  Write-Host "Bitte warten Sie einen Moment, Prozesse laufen noch......." -ForegroundColor Yellow
  $result = controllBackup $PathSrc $PathBck # Ruft funktion zur Überprüfung auf und speichert Rückgabewert
  Write-Host $result[0] -BackgroundColor $result[1] -ForegroundColor Black # Gibt Resultat in Grün oder Rot an
  Write-Output "------------------------" | Out-file $TopLog -Append
  Write-Output $result[0] | Out-file $TopLog -Append
  CreateLog 2 # Beendet die Log File
  if ($userMail -ne "") {
    Write-Mail $userMail $result[0] $result[1] # am Schluss E-Mail versenden
  }
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
    $Global:BckSucces = "gelungen"; # Mail -> Das Backup ist gelungen
    return ("Das Backup ist gelungen", "Green") # Gibt String mit Farbe zurück
  }
  else {
    # Nicht alle Elemente wurden kopiert
    $BckSucces = "fehlgeschlagen"; # Mail -> Das Backup ist fehlgeschlagen
    return ("Das Backup ist fehlgeschlagen", "Red") # Gibt String mit Farbe zurück
  }
}
# Kontrolliert den Hash des Source und Backup Ordners
function checkHash ([string]$Hash1, [string]$Hash2) {
  # Weisst den Hash aller Files im Source Ordner einer Variablen zu
  [string]$SrcHash = (Get-ChildItem -Path $Hash1 -Recurse | Where-Object { !($_.PSIsContainer) }) |
  ForEach-Object { (Get-FileHash -Path $_.FullName -a md5).Hash };
  # Weisst den Hash aller Files im Backup Ordner einer Variablen zu
  [string]$BckHash = (Get-ChildItem -Path $Hash2 -Recurse | Where-Object { !($_.PSIsContainer) }) |
  ForEach-Object { (Get-FileHash -Path $_.FullName -a md5).Hash };
  # Stimmt der Hash des Source und Backup Ordner überei?
  if ($SrcHash -eq $BckHash) {
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
function CreateLog([int]$Ablauf) {
  switch ($Ablauf) {
    1 {
      Write-Output " ------------------ " | Out-File $TopLog -Append
      Write-Output "Verlauf wurde gestartet am: $date" | Out-File $TopLog -Append
      Write-Output " ------------------ " | Out-File $TopLog -Append
      Write-Output "Quelverzeichnis ist: $TopSrc" | Out-File $TopLog -Append
      Write-Output "Zielverzeichnis ist: $TopSrc" | Out-File $TopLog -Append
    }
    2 {
      Write-Output "Skript beendet" | Out-File $TopLog -Append
      Write-Output "                " | Out-File $TopLog -Append
    }
  }
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

# Öffnet das GUI
# Funtkioniert momentan nicht in einer Funktion, auspacken zum testen
function OpenGui() {
  Add-Type -AssemblyName PresentationFramework
  $xamlFile = "..\GUI_(VS Studio)\Forms\MainWindow.xaml"
  #create window
  $inputXML = Get-Content $xamlFile -Raw
  $inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
  [XML]$XAML = $inputXML

  #Read XAML
  $reader = (New-Object System.Xml.XmlNodeReader $xaml)
  try {
    $window = [Windows.Markup.XamlReader]::Load( $reader )
  }
  catch {
    Write-Warning $_.Exception
    throw
  }

  # Create variables based on form control names.
  # Variable will be named as 'var_<control name>'

  $xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)"
    try {
      Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    }
    catch {
      throw
    }
  }
  # Hollt alle Variablen des GUI und speichert sie in Powershell Variablen
  Get-Variable var_*

  # Code Blöcke, welche beim betätigen eines Klicks im GUI ausgelöst werden
  $var_choiceSrc.Add_Click( {
      $Global:TopSrc = (Get-Folder + "\")
      $var_topSrc.Text = ($TopSrc + "\")
      $Global:TopSrc = $var_topSrc.Text
    })

  $var_choiceBck.Add_Click( {
      $Global:TopBck = Get-Folder
      $var_topBck.Text = ($TopBck + "\Backup $date\")
      $Global:TopBck = $var_topBck.Text
    })

  $var_choiceLog.Add_Click( {
      $Global:TopLog = Get-Folder
      $var_topLog.Text = ($TopLog + "\Log_$date.txt")
      $Global:TopLog = $var_topLog.Text
    })

  $var_choiceSave.Add_Click( {
      $Global:userMail = $var_userMail.Text 
      CreateBackup # Ruft die Backup Funktion auf
    })

  $Null = $window.ShowDialog()
}
# Schreibt eine E-Mail, ob das Backup erfolgreich war oder nicht (mit Logfile)
function Write-Mail([string]$userMail, [string]$title, [string]$farbeDringlichkeit) {
  [string]$log = $TopLog # aktuelle Logfile
  [int]$totFlsSrc = (Get-ChildItem $TopSrc -Recurse | Where-Object { !($_.PSIsContainer) }).Count
  # Zähler, wie viele Elemente kopiert wurden
  [int]$totFlsBck = (Get-ChildItem $TopBck -Recurse | Where-Object { !($_.PSIsContainer) }).Count


  if ($farbeDringlichkeit -eq "Green") {
    [int]$importance = 1 # Erfolgreich ist eine normale Mail 
  }
  else {
    [int]$importance = 2 # Fehlschlag ist eine dringende Mail
  }
  
  $Outlook = New-Object -ComObject Outlook.Application # Outlook öffnen
  $Mail = $Outlook.CreateItem(0) # In Outlook (Mail Editor öffnen) / Mail erstellen

  $Mail.To = "$userMail" # E-Mail des Empfängers
  $Mail.Subject = "$title" # Titel
  # Nachricht
  $Mail.Body = "Es wurden $totFlsSrc Elemente von $totFlsBck kopiert.`nGenauere Informationen befinden sich im Anhang."
  $Mail.importance = $importance # Dringlichkeit der Mail
  try {
    $Mail.Attachments.Add($log) # Logfile im Anhang hinzufügen
  }
  catch {
    Write-Error "$_"
  }

  $Mail.Send() # Nachricht senden

  # $Outlook.Quit() # Outlook schliessen
}

# -------------------------------------------------------------
# Hauptcode
# -------------------------------------------------------------

# Logdatei erstellen
OpenGui # CreateBackup Funktion aufrufen


Write-Host "Das Programm endet hier" -BackgroundColor White -ForegroundColor Black