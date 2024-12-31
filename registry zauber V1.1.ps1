#Autor: github.com/codekan
#random registry rambling
#blueprint for other script requiring registry values to be changed

$mainpath = "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI\"

$regpath_container = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI\" -Name

$mainpath = "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI\"

$extra_anhang = "\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" 


ForEach($singlething in $regpath_container){
  $subbo = "$mainpath$singlething\"
  $bonk = Get-ChildItem -Path "$subbo"
  ForEach($item in $bonk){
    [string]$beep = "$item"
    [string]$beep = $beep.substring("18")
    $beep = "HKLM:$beep$extra_anhang"
    if(Test-Path $beep){
      Write-Host "VALID PATH: $beep"
      $badoop = Get-ItemPropertyValue -Path $beep -Name "MSISupported"
      if($badoop -ne 1){
        Set-Itemproperty -path $beep -Name "MSISupported" -Value 1
      }
    }  
  }
}
