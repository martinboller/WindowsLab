### Adds users to FGPP Group

## Variables: Domain and file information
$DomainName = "DC=siemlab,DC=dk"
$FGPPGroup = "CN=Users-FGPP,OU=Users,DC=siemlab,DC=dk"
$CSVfile = "C:\UsersFGPP.csv"

# Add members from CSV file to group
Import-Module ActiveDirectory
Import-Csv $CSVfile | ForEach-Object {
 $samAccountName = $_."samAccountName"
 Add-ADGroupMember -Identity $FGPPGroup -Members $samAccountName
}