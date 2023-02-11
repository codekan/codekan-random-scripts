if (!(Get-Module -Name Microsoft.PowerShell.Archive -ListAvailable)) {
    Write-Host "Microsoft.PowerShell.Archive-Modul wurde nicht gefunden. Lade es herunter..."
    Install-Module -Name Microsoft.PowerShell.Archive -Force
} else {
    Write-Host "Microsoft.PowerShell.Archive-Modul ist bereits installiert."
}

if (!(Get-Module -Name System.Net.WebClient -ListAvailable)) {
    Write-Host "System.Net.WebClient-Modul wurde nicht gefunden. Lade es herunter..."
    Install-Module -Name System.Net.WebClient -Force
} else {
    Write-Host "System.Net.WebClient-Modul ist bereits installiert."
}

if (!(Get-Module -Name Microsoft.NET.Framework -ListAvailable)) {
    Write-Host ".NET-Framework-Modul wurde nicht gefunden. Lade es herunter..."
    Install-Module -Name Microsoft.NET.Framework -Force
} else {
    Write-Host ".NET-Framework-Modul ist bereits installiert."
}


$url = "https://openhardwaremonitor.org/downloads/"
$webClient = New-Object System.Net.WebClient
$html = $webClient.DownloadString($url)

# Verwendung von Regulären Ausdrücken, um nach URLs zu suchen, die "https://openhardwaremonitor.org/files/openhardwaremonitor-v" enthalten
$downloadLink = Select-String -InputObject $html -Pattern 'href="(https://openhardwaremonitor.org/files/openhardwaremonitor-v.*)"' -AllMatches |
                Select-Object -ExpandProperty Matches |
                Select-Object -ExpandProperty Value

# Sortierung der Links nach Version
$sortedLinks = $downloadLink | Sort-Object { [version]$_.split("-v")[1].split(".zip")[0] } -Descending
$sortedLinks = $sortedLinks[0].Split('"')[1]

# Ausgabe des reinen Download-Links
Write-Output "The latest download link is: "
Write-Output $sortedLinks

# Herunterladen der Zip-Datei
$filePath = "$env:temp\openhardwaremonitor.zip"
$webClient.DownloadFile($sortedLinks, $filePath)

# Entpacken der Zip-Datei
if ((Test-Path $env:temp\openhardwaremonitor) -eq $false){
Write-Host "Entpackter Pfad existiert noch nicht also wird er jetzt erstellt"
Expand-Archive -Path $filePath -DestinationPath "$env:temp\openhardwaremonitor"
}

Get-ChildItem "$env:temp\openhardwaremonitor\openhardwaremonitor"

if((get-process -Processname *openhardware*) -eq $null){
Start-Process "$env:temp\openhardwaremonitor\openhardwaremonitor\OpenHardwareMonitor.exe" -WindowStyle Hidden
}

Add-Type -Path "C:\Users\OkansPC\AppData\Local\Temp\openhardwaremonitor\openhardwaremonitor\OpenHardwareMonitorLib.dll"

$computer = New-Object OpenHardwareMonitor.Hardware.Computer
$computer.Open()
$computer.CPUEnabled = $true
$computer.Accept()

$cpuTemperature = 0

While ($true){
foreach ($hardware in $computer.Hardware) {
if ($hardware.HardwareType -eq "CPU") {
$hardware.Update()
foreach ($sensor in $hardware.Sensors) {
if ($sensor.SensorType -eq "Temperature") {
$cpuTemperature = $sensor.Value
Write-Output "The current CPU temperature is: $cpuTemperature °C"
Sleep 10
}
}
}
}
}


