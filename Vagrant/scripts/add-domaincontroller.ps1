# Purpose: adds a DC to the "siemlab.dk" domain
# Source: https://github.com/StefanScherer/adfs2
param ([String] $ip)

$subnet = $ip -replace "\.\d+$", ""

$domain= "siemlab.dk"

if ((gwmi win32_computersystem).partofdomain -eq $false) {

  Write-Host 'Installing RSAT tools'
  Import-Module ServerManager
  Add-WindowsFeature RSAT-AD-PowerShell,RSAT-AD-AdminCenter,DNS,RSAT-DNS-Server
  Write-Host 'Creating domain controller'
  # Disable password complexity policy
  # secedit /export /cfg C:\secpol.cfg
  # (gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
  # secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
  # rm -force C:\secpol.cfg -confirm:$false

  # Set administrator password
  $computerName = $env:COMPUTERNAME
  $PlainPassword = "vagrant" # "P@ssw0rd"
  $SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
  $adPlainPassword = "AdRestoreP@ssw0rd"
  $AdSafeModePassword = $adPlainPassword | ConvertTo-SecureString -AsPlainText -Force
  $adminUser = "administrator@$domain"
  $SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
  $adCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminUser, $SecurePassword

  # Windows Server 2022
  Install-WindowsFeature AD-domain-services
  Import-Module ADDSDeployment
  
  Install-ADDSDomainController `
    -Credential $adCredential `
    -SkipPreChecks `
    -SafeModeAdministratorPassword $adSafeModePassword `
    -CreateDnsDelegation:$false `
    -NoGlobalCatalog:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainName $domain `
    -SkipAutoConfigureDns:$true `
    -InstallDns:$true `
    -ReplicationSourceDC "dc1.$domain" `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$true `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true  

  $newDNSServers = "192.168.10.41", "192.168.10.42"
  $adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -And ($_.IPAddress).StartsWith($subnet) }
  if ($adapters) {
    Write-Host Setting DNS
    $adapters | ForEach-Object {$_.SetDNSServerSearchOrder($newDNSServers)}
  }
  
  Write-Host "Syncing DNS"
  Sync-DnsServerZone -passThru
  
  # Write-Host "Excluding NAT interface from DNS"
  # $nics=Get-WmiObject "Win32_NetworkAdapterConfiguration where IPEnabled='TRUE'" |? { $_.IPAddress[0] -ilike "192.168.10.*" }
  # $dnslistenip=$nics.IPAddress
  # $dnslistenip
  # #dnscmd /ResetListenAddresses  $dnslistenip "192.168.10.42"

  $nics=Get-WmiObject "Win32_NetworkAdapterConfiguration where IPEnabled='TRUE'" |? { $_.IPAddress[0] -ilike "10.*" }
    foreach($nic in $nics)
    {
      $nic.DomainDNSRegistrationEnabled = $false
      $nic.SetDynamicDNSRegistration($false) |Out-Null
    }
  }
  
  Restart-Service DNS
  
Start-Sleep -s 30
#exit 0