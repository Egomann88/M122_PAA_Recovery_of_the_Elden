[string]$topDir = Get-Location; # Aktueller Pfad zum Skript
[string]$startFolder = "topSrc"; # Von welchen ordner ein Backup gemacht werden soll
[string]$date = Get-Date -Format "yyyy-MM-dd"; # aktuelles Datum für den Backup Ordner
[string]$newBackupFolder = "\backUp" + $date; # Name des Backup Ordners
[string]$newDir = $topDir + $newBackupFolder; # Pfad des neuen Backup Ordners

<# 
    Array mit allen Ordnern von denen ein Backup gemacht soll.
    Array wird dann automatisch durchgegangen. Wird in einem
    Ordner ein anderer Ordner entdeckt, wird der Teilpfad vom
    Start Ordner her in das Array gespeichert, damit das Skript
    auch in diesen Ordner greift und die Dateien kopiert. Wird
    darin wieder ein Ordner gefunden, wird dieser wieder im
    Array hinzugefügt usw. bis das Array durch die For durch ist.
    Als Teilpfad ist der Teil bezeichnet, der nach topDir folgt.
    Ohne ein "\" zu Beginn.
#>
$toBackupFolder = New-Object System.Collections.ArrayList
$toBackupFolder.Add($startFolder) # Fügt den ersten Ordner hinzu

# Darin werden alle Dateien in einem Ordnern gespeichert
$FileNames;

<# 
    Überprüft, ob schon ein Backup Ordner von heute existiert
    Wenn ja, wird das Programm abgebrochen, ansonsten wird
    dieser erstellt
#>
if (-not (Test-Path -LiteralPath $newDir)) {
    
    <# 
        Versucht den neuen Ordner zu erstellen. Tritt dabei ein Error auf,
        wird dieser durch das catch abgefangen und das Skript wird beendet.
        https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-exceptions?view=powershell-7.2#trycatch
    #>
    try {
        <# 
            Erstellt den Backup Ordner
            -ErrorAction Stop verhindert das weiterführen des Befehlt (somit keine
            Ausgabe von einem Error), damit man diesen mit catch abfangen kann
            Out-Null verhindert, dass irgendwelche Ausgaben gemacht werden sollten.
        #>
        New-Item -Path $newDir -ItemType Directory -ErrorAction Stop | Out-Null
        Write-Host -ForegroundColor Green "Successfully created directory '$newDir'."
    }
    catch {
        Write-Error -Message "Unable to create directory '$newDir'. Error was: $_"
        Exit
    }

    <# 
        Geht durch das Array durch, in dem sich die Pfade
        befinden mit den Ordnern die kopiert werden sollten.
        Kein Foreach, da dies ein Error gab, dass die Grösse
        nicht in nachhinein veränder werden darf.
    #>
    for ($i = 0; $i -lt $toBackupFolder.Count; $i++) {
       

        <# 
            Listet alle Dateien im Ordner auf die vorhanden sind
            $topDir bleibt immer gleich. Dazu wurd mit toBackupFolder[$i] der Pfad
            hinzugefügt von dem Ordner, von dem das Backup gemacht werden sollte.
            -Force: Holt alle Dateien die vorhanden sind. Inkl. versteckte und Systemdateien
        #>
        $FileNames = Get-ChildItem -Path ($topDir + "\" + $toBackupFolder[$i]) -Force
        
        # Geht durch alle Datein durch, die im Ordner gefunden wurden
        foreach ($file in $FileNames) {

            <# 
                überprüft, ob die Datei ein Ordner ist oder nicht. Wenn ja, 
                wird im Backup Ordner dieser Ordner auch erstellt und der
                Teilpfad in Array $toBackupFolder hinzugefügt, damit in 
                diesem Ordner auch noch nach Dateien geschaut wird.
                Wenn nein, ist es eine Datei die kopiert werden kann.
            #>
            if (Test-Path -LiteralPath ($topDir + "\" + $toBackupFolder[$i] + "\" + $file) -PathType Container) {
                
                # erstellt den Ordner im Backup Ordner
                try {
                    New-Item -Path ($topDir + "\" + $newBackupFolder + "\" + $toBackupFolder[$i] + "\" + $file) -ItemType Directory -ErrorAction Stop | Out-Null

                    <# 
                        Fügt den Teilpfad im Array hinzu.
                        in $toBackupFolder[$i] ist ja der aktuelle Ordner Teilpfad
                        drin und in diesem befindet sich ja der neue Ordner. Daher
                        werden beide Teile kompiniert im Array hinzugefügt 
                    #>
                    $toBackupFolder.Add($toBackupFolder[$i] + "\" + $file)
                }
                catch {
                    Write-Error -Message "Unable to create directory '$newDir'. Error was: $_"
                    Exit
                }
            }
            else {
                <# 
                    Es werden vorsichthalber ausschliesslich .txt
                    Dateien kopiert, damit nicht was kopiert wird
                    was nicht sollte. Soll alles kopiert werden, 
                    kann auf den Switch verzeichtet werden
                #>
                switch ($file.extension) {
                    ".txt" {
                        try {
                            Copy-Item ($topDir + "\" + $toBackupFolder[$i] + "\" + $file) -Destination ($topDir + $newBackupFolder + "\" + $toBackupFolder[$i]) -ErrorAction Stop | Out-Null
                            Write-Host -ForegroundColor Green "Successfully copied file '$file'."
                        }
                        catch {
                            Write-Error -Message "Unable to copy item $file. Error was: $_"
                            Exit
                        }
                    }
                
                    # alle anderen vorhanden Dateien werden einfach ausgegeben
                    default {
                        Write-Host -ForegroundColor Yellow "Not moved: " + $file
                    }
                }
            }
        }
    }

}
else {
    Write-Host -ForegroundColor Red "Backup already existed"
    # Löscht den Backup Ordner direkt. Nur für die Entwicklung gedacht
    # Remove-item $newDir
}