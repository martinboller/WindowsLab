$domain= "siemlab.dk"

Write-Host 'Adding A and NS records for DC2'

if ($env:COMPUTERNAME -imatch 'dc1') {
   Write-Host 'A records for Workstations'
   Add-DnsServerResourceRecordA `
      -Name win10a `
      -ZoneName $domain `
      -IPv4Address 192.168.56.44
      Add-DnsServerResourceRecordA `
      -Name win10a `
      -ZoneName $domain `
      -IPv4Address 192.168.56.45
      Add-DnsServerResourceRecordA `
      -Name win11 `
      -ZoneName $domain `
      -IPv4Address 192.168.56.46

   Write-Host 'A and NS records for dc2'
   Add-DnsServerResourceRecordA `
      -Name dc2 `
      -ZoneName $domain `
      -IPv4Address 192.168.56.42

   Add-DnsServerResourceRecordA  `
      -Name dc2 `
      -ZoneName $domain `
      -IPv4Address 192.168.10.42
      
   Add-DnsServerResourceRecord -ZoneName $domain `
      -ns -ComputerName dc1.$domain `
      -name $domain `
      -NameServer dc2.$domain
      
   Write-Host 'A and NS records for internal DNS'
   Add-DnsServerResourceRecordA -Name aabfw001 -ZoneName $domain -IPv4Address 192.168.10.1
   Add-DnsServerResourceRecord -ZoneName $domain -ns -ComputerName dc1.$domain -name $domain -NameServer aabfw001.$domain
   Write-Host 'Configure Zone Transfers to internal Name Server'
   Set-DnsServerPrimaryZone -ComputerName dc1.siemlab.dk -ZoneName siemlab.dk -SecureSecondaries TransferToZoneNameServer -Notify NotifyServers -NotifyServers 192.168.10.1

   Write-Host 'Set Serial number of DNS Zone'
   $serial = Get-Date -Format "MMddHHmmss"
   $oldsoa = ""
   $newsoa = ""
   $oldsoa = Get-DnsServerResourceRecord `
      -ComputerName dc1.$domain `
      -ZoneName $domain `
      -Name $domain `
      -RRType SOA
   $newsoa = $oldsoa.Clone()
   $newsoa.RecordData.SerialNumber = $serial
   Set-DnsServerResourceRecord `
      -ComputerName dc1.$domain `
      -OldInputObject $oldsoa `
      -NewInputObject $newsoa `
      -ZoneName $domain `
      -PassThru

   Write-Host "Initiating Zone transfer"
   Start-DnsServerZoneTransfer `
      -ComputerName dc1.$domain `
      -FullTransfer `
      -Name $domain `
}

Write-Host 'Finished adding/modifying A, NS, and SOA'
