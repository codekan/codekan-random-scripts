#Powershell-Skript für das Erstellen von Backups für einen Minecraft-Server
#Wenn man so einen Server hostet stürzt dieser manchmal ab und die Datei für die Welt wird beschädigt, sodass die Welt verloren geht
#Dieses Skript sichert in einem definierbaren Intervall den Server-Ordner in anderen Verzeichnissen mit einer maximalen Backup-Menge (FIFO)
#Falls der Server abstürzt und die Welt beschädigt wird, ersetzt man einfach den Server-Ordner mit dem letzten Backup
#Das Skript prüft auch regelmäßig, ob der Server-Prozess(Java) läuft und stoppt andernfalls das Generieren von Backups, damit die nützlichen Backups nicht überschrieben werden

$backup_folder_count = 0
$check_mcserver_running = Get-Process -Name cmd -ErrorAction SilentlyContinue
while($true)
    {
    while ($check_mcserver_running -ne $null)
        {
        Write-Host("mc server läuft gerade")
        Start-Sleep -s 1800
        $backup_folder_count = $backup_folder_count + 1
        $check_path = Test-Path C:\Users\Admin\Desktop\backup_folder\$backup_folder_count -PathType Any -IsValid
        if($check_path -eq $true)
            {
            Remove-Item -Path C:\Users\Admin\Desktop\backup_folder\$backup_folder_count -Include *.* -Recurse -Force
            Remove-Item -Path C:\Users\Admin\Desktop\backup_folder\$backup_folder_count -Force -Recurse
            }
        New-Item -Path C:\Users\Admin\Desktop\backup_folder\$backup_folder_count -ItemType "directory"
        Copy-Item -Path C:\Users\Admin\Desktop\SkyFactory-4_Server_4.2.2 -Destination C:\Users\Admin\Desktop\backup_folder\$backup_folder_count -Recurse -Force
        if ($backup_folder_count -eq 12)
            {
            $backup_folder_count = 0
            }
        $check_mcserver_running = Get-Process -Name cmd -ErrorAction SilentlyContinue
        }
    while($check_mcserver_running -eq $null)
        {
        Write-Host("mc server is not running")
        Start-Sleep -s 60
        $check_mcserver_running = Get-Process -Name cmd -ErrorAction SilentlyContinue
        }
    }