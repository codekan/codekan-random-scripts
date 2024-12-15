# Skript zum CPU-Priorität auf normal setzen für eine Liste von Prozessen
# Warte 5 Minuten (300 Sekunden)
#Start-Sleep -Seconds 300

# Liste der Prozessnamen, die überprüft werden sollen
$ProcessList = @(
    "steamwebhelper",
    "epicwebhelper",
    "msedgewebview2"
)

# Funktion, um die CPU-Priorität zu ändern
function Set-ProcessPriority {
    param (
        [string]$ProcessName,
        [string]$Priority = "High"  # Mögliche Werte: Low, BelowNormal, Normal, AboveNormal, High, RealTime
    )

    try {
        $processes = Get-Process -Name $ProcessName -ErrorAction Stop
        foreach ($process in $processes) {
            $process.PriorityClass = $Priority
            Write-Output "Priorität für Prozess '$ProcessName' (PID: $($process.Id)) wurde auf '$Priority' gesetzt."
        }
    } catch {
        Write-Warning "Prozess '$ProcessName' konnte nicht gefunden werden oder es gab einen Fehler: $_"
    }
}

# Alle Prozesse in der Liste durchgehen und für jeden Prozess mit dem Namen Priorität setzen
foreach ($processName in $ProcessList) {
    Set-ProcessPriority -ProcessName $processName -Priority "normal"
}

Write-Output "Skript abgeschlossen."
