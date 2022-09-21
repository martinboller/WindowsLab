## Adds users to FGPP Group

## Variables: Domain and file information
$DomainName = "DC=siemlab,DC=dk"
$FGPPGroup = "CN=Users-FGPP,OU=Users,DC=siemlab,DC=dk"
$CSVfile = "UsersChangePW"
$CSVFilePath = "C:\"
$CSVfileExtension = ".csv"
$currentDate = (get-date -Format "yyyyMMddHHmmss")

$CSVfileName = ("$CSVfilePath" + "$CSVfile" + "$CSVFileExtension")
$newCSVfileName = ("$CSVfilePath" + "$CSVfile" + "_" + "$currentdate" + "$CSVfileExtension")

# Add members from CSV file to group
Import-Module ActiveDirectory
Import-Csv ($CSVfileName) | ForEach-Object {
 $samAccountName = $_."samAccountName"
 Set-ADUser -Identity $samAccountName -ChangePasswordAtLogon:$True
 Add-ADGroupMember -Identity $FGPPGroup -Members $samAccountName
}

Rename-Item -Path $CSVfileName -newname $newCSVfileName