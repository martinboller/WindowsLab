rem http://www.windows-commandline.com/disable-automatic-updates-command-line/
rem reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 1 /f

rem remove optional WSUS server settings
rem reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f

rem even harder, disable windows update service
rem sc config wuauserv start= disabled
rem net stop wuauserv

rem if exist C:\Windows\Temp\win-updates.log (
rem   echo Show Windows Updates log file C:\Windows\Temp\win-updates.log
rem   dir C:\Windows\Temp\win-updates.log
rem   type C:\Windows\Temp\win-updates.log
  rem output of type command is not fully shown in packer/ssh session, so try PowerShell
  rem but it will hang if log file is about 22 KByte
  rem powershell -command "Get-Content C:\Windows\Temp\win-updates.log"
rem   echo End of Windows Updates log file C:\Windows\Temp\win-updates.log
rem )
