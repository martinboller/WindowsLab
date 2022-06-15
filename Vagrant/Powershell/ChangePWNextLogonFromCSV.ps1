Import-Module ActiveDirectory
Import-Csv "C:\ChangePWNextLogon.csv" | ForEach-Object {
 $samAccountName = $_."samAccountName"
Set-ADUser -Identity $samAccountName -ChangePasswordAtLogon $true
}