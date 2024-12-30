#Autor: github.com/codekan
#Das Skript soll einen Registry Value für alle PCI / PCIe-Geräte verändern, sodass alle das MSI- statt dem IRQ-Protokoll benutzen
#MSI statt IRQ reduziert softwareseitigen Overhead und erhöht Performance / reduziert Systemlatenzen
#Interrupt-Sharing wird so vermieden
#Mehr Informationen: https://de.wikipedia.org/wiki/Message-Signaled_Interrupts


$mainpath = "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI\"

$regpath_container = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI\" -Name

$mainpath = "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI\"

$extra_anhang = "\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" 


ForEach($singlething in $regpath_container){
  $subbo = "$mainpath$singlething\"
  $bonk = Get-ChildItem -Path "$subbo"
  #registry key umwandeln in hklm:\ am anfang sonst klappt test-path nicht
  ForEach($item in $bonk){
  #Pfad erweitern um Wunschpfad für MSIEnabled-Registry-Value zu finden
    [string]$item = $item+"\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
    [string]$item = $item -replace ("HKEY_LOCAL_MACHINE", "HKLM:\")
    if(Test-Path -LiteralPath $item){
        #Backtick für Zeilenumbruch
        Write-Host "PCI / PCIe-Gerät mit MSI-Support gefunden: " ` 
        $item
        $item_msi_check = (Get-ItemProperty -Path $item -Name MSISupported).MSISupported
        if($item_msi_check -eq 0){
            Write-Host -Foreground Red "MSI-Protokoll für Gerät deaktiviert" `
            "Korrektur wird durchgeführt..."
            Set-ItemProperty -Path $item -Name MSISupported -Value 1
            Write-Host -ForegroundColor Green "MSI-Protokoll eingeschaltet für: " `
            $item
            }
            else{
            Write-Host -ForegroundColor Green "MSI-Protokoll bereits aktiviert für: " `
            $item
            }
        }
    }
  }
