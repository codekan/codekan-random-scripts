#Execution Policy für den Prozess uneingeschränkt setzen, damit die Installation nicht durch fehlende Berechtigungen fehlt
Set-ExecutionPolicy Unrestricted -Scope Process -Force
# Windows Defender Average CPU Load auf 5% setzen - Sonst zu viel Load auf CPU - Ist nur eine Testumgebung also halb so wild
Set-MpPreference -ScanAvgCPULoadFactor 5
# TLS 1.2 forcieren - Windows Server 2016 z.B. nutzt Default TLS 1.1 - Wenn dein Webserver TLS 1.1 aus hat, failt der Download
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
iex ((New-Object System.Net.WebClient).DownloadString('https://install.mondoo.com/ps1/cnspec'))
iex ((New-Object System.Net.WebClient).DownloadString('https://install.mondoo.com/ps1'))
# Registrieren von cnspec Windows Agent im Mondoo Dashboard
# Token nötig, wird bei main.tf-Ausführung manuell eingegeben
Install-Mondoo -RegistrationToken '${var.mondoo_token_windows}' -Service enable -UpdateTask enable -Time 12:00 -Interval 3
# cnspec Windows Agent lokalen Scan starten - Daten landen dann im Mondoo Dashboard
cnspec scan local
# T E S T
New-Item -Path ([System.Environment]::GetFolderPath('Desktop')) -Name \"NeuerOrdner\" -ItemType Directory
