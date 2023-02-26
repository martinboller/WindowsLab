
$newDNSServers = "192.168.10.41", "192.168.10.42"
$gw = "192.168.10.1"

$adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -And $_.DHCPEnabled -EQ $false }
if ($adapters) {
  Write-Host Setting DNS
  $adapters | ForEach-Object {$_.SetDNSServerSearchOrder($newDNSServers)}
  Write-Host Setting Gateway
  $adapters | ForEach-Object {$_.SetGateways($gw)}
}

$InternalDns = "192.168.10.1"
if ($env:COMPUTERNAME -ilike 'dc*') {
  Import-Module DnsServer
  Write-Host 'Configure DNS Forwarder to LAB DNS on DC1'
  Set-DnsServerForwarder -IPAddress $InternalDns -PassThru
}

  Write-Host 'Disable DNS registration on Vagrant 10.* adapter'
  $nics=Get-WmiObject "Win32_NetworkAdapterConfiguration where IPEnabled='TRUE'" |? { $_.IPAddress[0] -ilike "10.*" }
  foreach($nic in $nics)
  {
    $nic.DomainDNSRegistrationEnabled = $false
    $nic.SetDynamicDNSRegistration($false) | Out-Null
  }

  Write-Host 'Install bginfo'
  . c:\vagrant\scripts\install-bginfo.ps1
