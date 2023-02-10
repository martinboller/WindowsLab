# Purpose: Creates the "siemlab.dk" domain
# Source: https://github.com/StefanScherer/adfs2
param ([String] $ip)

$subnet = $ip -replace "\.\d+$", ""

$domain= "siemlab.dk"

if ((gwmi win32_computersystem).partofdomain -eq $false) {

  Write-Host 'Installing RSAT tools'
  Import-Module ServerManager
  Add-WindowsFeature RSAT-AD-PowerShell,RSAT-AD-AdminCenter,RSAT-DNS-Server,DNS

  Write-Host 'Creating domain controller'
  # Disable password complexity policy
  secedit /export /cfg C:\secpol.cfg
  (gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
  secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
  rm -force C:\secpol.cfg -confirm:$false

  # Set administrator password
  $computerName = $env:COMPUTERNAME
  $adminPassword = "vagrant"
  $adminUser = [ADSI] "WinNT://$computerName/Administrator,User"
  $adminUser.SetPassword($adminPassword)

  $PlainPassword = "vagrant" # "P@ssw0rd"
  $SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force

  # Windows Server 2022
  Install-WindowsFeature AD-domain-services
  Import-Module ADDSDeployment
  Install-ADDSForest `
    -SafeModeAdministratorPassword $SecurePassword `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "7" `
    -DomainName $domain `
    -DomainNetbiosName "SIEMLAB" `
    -ForestMode "7" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$true `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true

  $newDNSServers = "192.168.10.41", "192.168.10.42", "192.168.10.1"
  $adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -And ($_.IPAddress).StartsWith($subnet) }
  if ($adapters) {
    Write-Host Setting DNS
    $adapters | ForEach-Object {$_.SetDNSServerSearchOrder($newDNSServers)}
  }
  Write-Host "Setting timezone to UTC"
  c:\windows\system32\tzutil.exe /s "UTC"
  
  # Write-Host "Excluding NAT interface from DNS"
  # $nics=Get-WmiObject "Win32_NetworkAdapterConfiguration where IPEnabled='TRUE'" |? { $_.IPAddress[0] -ilike "192.168.10.*" }
  # $dnslistenip=$nics.IPAddress
  # $dnslistenip
  # dnscmd /ResetListenAddresses  $dnslistenip "192.168.10.41"
  
  $nics=Get-WmiObject "Win32_NetworkAdapterConfiguration where IPEnabled='TRUE'" |? { $_.IPAddress[0] -ilike "10.*" }
  foreach($nic in $nics)
  {
    $nic.DomainDNSRegistrationEnabled = $false
    $nic.SetDynamicDNSRegistration($false) |Out-Null
    }

 #Get-DnsServerResourceRecord -ZoneName $domain -type 1 -Name "@" |Select-Object HostName,RecordType -ExpandProperty RecordData |Where-Object {$_.IPv4Address -ilike "10.*"}|Remove-DnsServerResourceRecord
 $RRs= Get-DnsServerResourceRecord -ZoneName $domain -type 1 -Name "@"

 foreach($RR in $RRs)
 {
  if ( (Select-Object  -InputObject $RR HostName,RecordType -ExpandProperty RecordData).IPv4Address -ilike "10.*")
  { 
   Remove-DnsServerResourceRecord -ZoneName $domain -RRType A -Name "@" -RecordData $RR.RecordData.IPv4Address -Confirm
  }

 }

Restart-Service DNS
  
}
Start-Sleep -s 30
# Add DNS RRs for dc2 while we're at it
#Add-DnsServerResourceRecordA -Name dc2 -ZoneName $domain -IPv4Address 192.168.10.42
#Add-DnsServerResourceRecordA -Name dc2 -ZoneName $domain -IPv4Address 192.168.10.42
#Add-DnsServerResourceRecord -ZoneName $domain -ns -ComputerName dc1.$domain -name $domain -NameServer dc2.$domain
