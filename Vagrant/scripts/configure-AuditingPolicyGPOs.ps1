# Purpose: Installs the GPOs for the custom WinEventLog auditing policy.
Write-Host "Configuring auditing policy GPOS..."
$GPOName = 'Domain Controllers Enhanced Auditing Policy'
$OU = "ou=Domain Controllers,DC=siemlab,dc=dk"
Write-Host "Importing $GPOName..."
Import-GPO -BackupGpoName $GPOName -Path "c:\vagrant\resources\GPO\Domain_Controllers_Enhanced_Auditing_Policy" -TargetName $GPOName -CreateIfNeeded
$gpLinks = $null
$gPLinks = Get-ADOrganizationalUnit -Filter 'Name -like $OU' -Properties name,distinguishedName, gPLink, gPOptions
$GPO = Get-GPO -Name $GPOName
If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
{
    New-GPLink -Name $GPOName -Target $OU -Enforced yes
}
else
{
    Write-Host "GpLink $GPOName already linked on $OU. Moving On."
}
$GPOName = 'Servers Enhanced Auditing Policy'
$OU = "ou=Servers,DC=siemlab,dc=dk"
Write-Host "Importing $GPOName..."
Import-GPO -BackupGpoName $GPOName -Path "c:\vagrant\resources\GPO\Servers_Enhanced_Auditing_Policy" -TargetName $GPOName -CreateIfNeeded
$gpLinks = $null
$gPLinks = Get-ADOrganizationalUnit -Filter 'Name -like $OU' -Properties name,distinguishedName, gPLink, gPOptions
$GPO = Get-GPO -Name $GPOName
If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
{
    New-GPLink -Name $GPOName -Target $OU -Enforced yes
}
else
{
    Write-Host "GpLink $GPOName already linked on $OU. Moving On."
}

$GPOName = 'Workstations Enhanced Auditing Policy'
$OU = "ou=Workstations,DC=siemlab,dc=dk" 
Write-Host "Importing $GPOName..."
Import-GPO -BackupGpoName $GPOName -Path "c:\vagrant\resources\GPO\Workstations_Enhanced_Auditing_Policy" -TargetName $GPOName -CreateIfNeeded
$gpLinks = $null
$gPLinks = Get-ADOrganizationalUnit -Filter 'Name -like $OU' -Properties name,distinguishedName, gPLink, gPOptions
$GPO = Get-GPO -Name $GPOName
If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
{
    New-GPLink -Name $GPOName -Target $OU -Enforced yes
}
else
{
    Write-Host "GpLink $GPOName already linked on $OU. Moving On."
}


$GPOName = 'VulnScan Group Policy Object'
$OU = "DC=siemlab,dc=dk"
$DOMAIN = "siemlab.dk"
Write-Host "Importing $GPOName..."
Import-GPO -BackupGpoName $GPOName -Path "c:\vagrant\resources\GPO\vuln_scan" -MigrationTable "c:\vagrant\resources\GPO\vuln_scan\vulnscan.migtable"  -TargetName $GPOName -CreateIfNeeded
$gpLinks = $null
$gPLinks = Get-ADOrganizationalUnit -Filter 'Name -like $OU' -Properties name,distinguishedName, gPLink, gPOptions
$GPO = Get-GPO -Name $GPOName
If ($gPLinks.LinkedGroupPolicyObjects -notcontains $gpo.path)
{
    New-GPLink -Name $GPOName -Target $OU -Enforced yes
}
else
{
    Write-Host "GpLink $GPOName already linked on $OU. Moving On."
}