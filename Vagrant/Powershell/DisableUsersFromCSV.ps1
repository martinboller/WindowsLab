Import-Module ActiveDirectory
Import-Csv "C:\disableusers.csv" | ForEach-Object {
 $samAccountName = $_."samAccountName"
Get-ADUser -Identity $samAccountName | Disable-ADAccount
}