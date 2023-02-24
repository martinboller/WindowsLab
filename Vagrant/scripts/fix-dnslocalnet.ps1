$domain = "siemlab.dk"

Sync-DnsServerZone -Name $domain -Verbose -ErrorAction Ignore
Get-DnsServerZone -Name $domain -Verbose -ErrorAction Ignore

    # Remove any 10.* registrations from DNS for domain and DC's

    if ($env:COMPUTERNAME -ilike 'dc*') {
      $RRName = "@", "dc1", "dc2"
      foreach($hostname in $RRName)
        {
          $RRs= Get-DnsServerResourceRecord -ZoneName $domain -type 1 -Name $hostname -ErrorAction SilentlyContinue
          foreach($RR in $RRs)
          {
            if ( (Select-Object  -InputObject $RR HostName,RecordType -ExpandProperty RecordData).IPv4Address -ilike "10.*")
            { 
              Remove-DnsServerResourceRecord -ZoneName $domain -RRType A -Name $hostname -RecordData $RR.RecordData.IPv4Address -ErrorAction SilentlyContinue
            }
          }
      }
    }
