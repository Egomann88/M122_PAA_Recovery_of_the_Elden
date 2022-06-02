<#
Projekt; Recovery of the elden
Letzte Änderung: 02.06.2022 11:16
Erstellt von: Dominic Tosku & Justin Urbanek
Version: 0.5
Versionsumschreibung: In der Testphase
#>


# ----
# Gloable Variablen
# ----
$TopSrc = "C:\M122_PAA_Recovery_of_the_Elden\topSrc" # Verzeichnis, vom dem ein Backup gemacht wird
$TopBck = "C:\Pap Partnerarbeit\M122_PAA_Recovery_of_the_Elden\topBck" # Verzeichnis indem die Files abgelegt werden
$date = Get-Date -Format "dd.MM.yyyy HH:mm" # Akutelles Datum speichern
$TotalBackupedFilles = 0 # Zähler, wie viele Dateien insegesamt kopiert wurden

# ----
# * regex scheisse. Letztes Änderungsdatum wird überschrieben in diesen Powershell Skript
# ! Zerstört die Source File momentan, mit vorsicht geniessen
# ----
Set-Location -path "C:\M122_PAA_Recovery_of_the_Elden\bin"
$Location = Get-Location
$file = "C:\M122_PAA_Recovery_of_the_Elden\bin\Jo.txt"
$txtFileContent = (Get-Content $file -raw);
[regex]$pattern = 'Letzte Änderung: \d\d.\d\d.\d\d\d\d \d\d:\d\d'; # um die Letzte Änderung zu finden
# Der Begriff "Letze Änderung" wird mit dem akutellen Datum ersetzt
$pattern.Replace($txtFileContent,'Letzte Änderung: ' + $date, 1) | Set-Content $file


# ? 	[¬º-°]¬ 	[¬º-°]¬ 	[¬º-°]¬ 	[¬º-°]¬ 	[¬º-°]¬ 	[¬º-°]¬ 	[¬º-°]¬ 	[¬º-°]¬
# todo: [¬º-°]¬	[¬º-°]¬	[¬º-°]¬	[¬º-°]¬	[¬º-°]¬	[¬º-°]¬	[¬º-°]¬	[¬º-°]¬	[¬º-°]¬	[¬º-°]¬	[¬º-°]¬	[¬º-°]¬