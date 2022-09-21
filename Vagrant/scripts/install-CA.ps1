# Purpose: Install
# Source: https://learn.microsoft.com/en-us/powershell/module/adcsdeployment/install-adcscertificationauthority?view=windowsserver2022-ps

param ([String] $ip)

$subnet = $ip -replace "\.\d+$", ""

$domain= "siemlab.dk"

$user = "administrator@siemlab.dk"
$pass = ConvertTo-SecureString "vagrant" -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential $user, $pass

if ((gwmi win32_computersystem).partofdomain -eq $true) {
  If ($env:computername -eq "dc1") {
    Write-Host 'Installing Microsoft Enterprise Root CA'
    Install-WindowsFeature Adcs-Cert-Authority
    Add-WindowsFeature RSAT-ADCS,RSAT-ADCS-mgmt
    Import-Module ADCSDeployment
    Install-AdcsCertificationAuthority -Credential $DomainCred -CAType EnterpriseRootCa -CryptoProviderName "ECDSA_P256#Microsoft Software Key Storage Provider" -KeyLength 256 -HashAlgorithmName SHA256 -Force
    Write-Host 'Restarting Certificate Services'
    Restart-Service -Name CertSvc
    Start-Sleep -s 20
    Write-Host 'Adding Certificate Templates'
    Add-CATemplate -Name "DomainControllerAuthentication" -Force
    Add-CATemplate -Name "DomainController" -Force
    Add-CATemplate -Name "User" -Force
    Add-CATemplate -Name "Workstation" -Force
    Add-CATemplate -Name "EFS" -Force
    Add-CATemplate -Name "WebServer" -Force
    Add-CATemplate -Name "CTLSigning" -Force
    Add-CATemplate -Name "OCSPResponseSigning" -Force
    Add-CATemplate -Name "EFSRecovery" -Force
    Add-CATemplate -Name "IPSecIntermediateOnline" -Force
    Add-CATemplate -Name "MachineEnrollmentAgent" -Force
    #Add-CATemplate -Name "" -Force
    #Add-CATemplate -Name "" -Force
    #Add-CATemplate -Name "" -Force
    #Add-CATemplate -Name "" -Force
  }  
}
Start-Sleep -s 10
