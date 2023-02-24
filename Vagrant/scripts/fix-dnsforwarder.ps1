  
  $InternalDns = "192.168.10.1"
  if ($env:COMPUTERNAME -imatch 'dc1') {
    Write-Host 'Configure DNS Forwarder to LAB DNS on DC1'
    Set-DnsServerForwarder -IPAddress $InternalDns -PassThru
  } elseif ($env:COMPUTERNAME -imatch 'dc2') {
    Write-Host 'Configure DNS Forwarder to LAB DNS on DC2'
    Set-DnsServerForwarder -IPAddress $InternalDns -PassThru
  }
