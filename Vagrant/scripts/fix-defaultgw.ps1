
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
  Write-Host 'Configure DNS Forwarder to LAB DNS on DC1'
  Set-DnsServerForwarder -IPAddress $InternalDns -PassThru
}
