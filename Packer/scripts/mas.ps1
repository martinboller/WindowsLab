Write-Host Downloading mas-activation zip

New-Item -Path "c:\Tools" -Name "mas" -ItemType "directory"
Invoke-WebRequest -Uri "https://github.com/massgravel/Microsoft-Activation-Scripts/archive/refs/heads/master.zip" -OutFile 'C:\Tools\mas\mas.zip' -UseBasicParsing

Write-host Unpacking
Expand-Archive -Path 'C:\Tools\mas\mas.zip' -DestinationPath 'C:\Tools\mas\'
