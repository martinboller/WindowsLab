Set-ADAccountPassword -Identity 'CN=sy001vuln01, cn=Computers, dc=ad, dc=bollers, dc=dk' -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "This is a bad password" -Force)

