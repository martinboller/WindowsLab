# Purpose: Sets timezone to UTC, sets hostname, creates/joins domain.
# Source: https://github.com/StefanScherer/adfs2

$box = Get-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName -Name "ComputerName"
$box = $box.ComputerName.ToString().ToLower()
$domain = "siemlab.dk"

Write-Host "Setting timezone to UTC"
c:\windows\system32\tzutil.exe /s "UTC"

if ($env:COMPUTERNAME -imatch 'vagrant') {

  Write-Host 'Hostname is still the original one, skip provisioning for reboot'

  Write-Host -fore red 'Hint: vagrant reload' $box '--provision'

} elseif ((gwmi win32_computersystem).partofdomain -eq $false) {

  Write-Host -fore red "Current domain is set to 'workgroup'. Time to join the domain!"

  if ($env:COMPUTERNAME -imatch 'dc1') {
    Write-Host 'Install DC1 and create Domain'
    . c:\vagrant\scripts\create-domain.ps1 192.168.10.41
  } elseif ($env:COMPUTERNAME -imatch 'dc2') {
    Write-Host 'Install DC2'
    . c:\vagrant\scripts\add-domaincontroller.ps1 192.168.10.42
  } else {
    . c:\vagrant\scripts\join-domain.ps1
  }
  Write-Host -fore red 'Hint: vagrant reload' $box '--provision'

} else {

  Write-Host -fore green "I am domain joined!"

}


Write-Host 'Set default gateway and remove 10.* network from registering dns'
. C:\vagrant\scripts\fix-defaultgw.ps1
