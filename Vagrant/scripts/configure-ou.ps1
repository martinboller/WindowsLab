# Purpose: Sets up the Servers Workstations, and Jumpstations OUs

Write-Host "Creating Server. Workstations, and Jumpstations OUs..."
Write-Host "Creating Servers OU..."
if (!([ADSI]::Exists("LDAP://OU=Servers,DC=siemlab,DC=dk")))
{
    New-ADOrganizationalUnit -Name "Servers" -Server "dc1.siemlab.dk"
}
else
{
    Write-Host "Servers OU already exists. Moving On."
}
Write-Host "Creating Workstations OU"
if (!([ADSI]::Exists("LDAP://OU=Workstations,DC=siemlab,DC=dk")))
{
    New-ADOrganizationalUnit -Name "Workstations" -Server "dc1.siemlab.dk"
}
else
{
    Write-Host "Workstations OU already exists. Moving On."
}
Write-Host "Creating Jumpstations OU"
if (!([ADSI]::Exists("LDAP://OU=Jumpstations,DC=siemlab,DC=dk")))
{
    New-ADOrganizationalUnit -Name "Jumpstations" -Server "dc1.siemlab.dk"
}
else
{
    Write-Host "Jumpstations OU already exists. Moving On."
}
# Sysprep breaks auto-login. Let's restore it here:
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "vagrant"
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value "vagrant"
