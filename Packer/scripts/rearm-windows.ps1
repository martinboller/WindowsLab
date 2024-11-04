# Replaces "slmgr.vbs /rearm"
# https://powershell.org/forums/topic/run-command-quietly-start-process/
# https://msdn.microsoft.com/en-us/library/ee957713(v=vs.85).aspx

#Write-Host "Resetting the Windows evaluation timer"

$x = Get-WmiObject SoftwarelicensingService
$x.ReArmWindows()

#Write-Host Downloading mas-activation zip

#New-Item -Path "c:\Tools" -Name "mas" -ItemType "directory"
#Invoke-WebRequest -Uri "https://github.com/massgravel/Microsoft-Activation-Scripts/archive/refs/heads/master.zip" -OutFile 'C:\Tools\mas\mas.zip' -UseBasicParsing

#Write-host Unpacking
#Expand-Archive -Path 'C:\Tools\mas\mas.zip' -DestinationPath 'C:\Tools\mas\'

#c:\Tools\Microsoft-Activation-Scripts-master\MAS\All-In-One-Version\MAS_AIO-CRC32_8B16F764.cmd /KMS38