####################################################################
#                                                                   #
# Author:       Martin Boller                                       #
#                                                                   #
# Email:        martin.boller@sydbank.dk                                   #
# Last Update:  2020-10-27                                          #
# Version:      1.00                                                #
#                                                                   #
# Changes:      Initial version (1.00)                              #
#                                                                   #
#####################################################################
#
## Adds users to FGPP Group

## Variables: Domain and file information
$DomainName = "DC=siemlab,DC=dk"
$FGPPGroup = "CN=SY_Brugere-FGPP,OU=SY-Brugere,DC=siemlab,DC=dk"
$CSVfile = "C:\UsersFGPP.csv"

# Add members from CSV file to group
Import-Module ActiveDirectory
Import-Csv $CSVfile | ForEach-Object {
 $samAccountName = $_."samAccountName"
 Add-ADGroupMember -Identity $FGPPGroup -Members $samAccountName
}