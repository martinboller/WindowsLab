Set-ADAccountPassword -Identity 'CN=sy001vuln01, cn=Computers, dc=ad, dc=bollers, dc=dk' -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "This is a bad password" -Force)
Set-ADAccountPassword -Identity 'CN=sy001vuln02, cn=Computers, dc=ad, dc=bollers, dc=dk' -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "This is another bad password" -Force)
