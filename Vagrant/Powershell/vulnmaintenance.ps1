Set-ADAccountPassword -Identity 'CN=vuln01, OU=Servers, DC=siemlab, DC=dk' -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "This is a bad password" -Force)
Set-ADAccountPassword -Identity 'CN=vuln02, OU=Servers, DC=siemlab, DC=dk' -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "This is another bad password" -Force)
