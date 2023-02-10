# Purpose: Joins a Windows host to the siemlab.dk domain which was created with "create-domain.ps1".
# Source: https://github.com/StefanScherer/adfs2

$domain= "siemlab.dk"

Write-Host 'Join the domain'
$hostname = $(hostname)
$user = "SIEMLAB\vagrant"
$pass = ConvertTo-SecureString "vagrant" -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential $user, $pass

# Place the computer in the correct OU based on hostname
If ($hostname -eq "wef") {
  Add-Computer -DomainName "siemlab.dk" -credential $DomainCred -OUPath "ou=Servers,DC=siemlab,dc=dk" -PassThru
} ElseIf ($hostname -eq "win10a") {
  Write-Host "Adding Win10a to the domain. Sometimes this step times out. If that happens, just run 'vagrant reload win10a --provision'" #debug
  Add-Computer -DomainName "siemlab.dk" -credential $DomainCred -OUPath "ou=Workstations,DC=siemlab,dc=dk"
} ElseIf ($hostname -eq "win10b") {
  Write-Host "Adding Win10b to the domain. Sometimes this step times out. If that happens, just run 'vagrant reload win10b --provision'" #debug
  Add-Computer -DomainName "siemlab.dk" -credential $DomainCred -OUPath "ou=Jumpstations,DC=siemlab,dc=dk"
} Else {
  Add-Computer -DomainName "siemlab.dk" -credential $DomainCred -PassThru -OUPath "ou=Servers,DC=siemlab,dc=dk"
}

Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "vagrant"
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value "vagrant"

# Ensure that Windows Update starts
#Write-Host "Disabling Windows Updates and Windows Module Services"
Set-Service wuauserv -StartupType Enabled
Start-Service wuauserv
Set-Service TrustedInstaller -StartupType Enabled
Start-Service TrustedInstaller
