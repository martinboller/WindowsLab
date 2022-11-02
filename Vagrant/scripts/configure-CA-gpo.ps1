# Purpose: Installs the GPOs needed to specify Certificate Auto-Enrollment
Write-Host "Importing the GPO to specify Certificate Auto-Enrollment"
$GPOName = "Certificate Enrollment Group Policy Object"
$OU = "DC=siemlab,DC=dk"

# Import GPO
Import-GPO -BackupGpoName $GPOName -Path "c:\vagrant\resources\GPO\Cert-Enroll" -TargetName $GPOName -CreateIfNeeded
# Link to Domain
New-GPLink -Name $GPOName -Target $OU -Enforced yes

Invoke-GPUpdate -Force