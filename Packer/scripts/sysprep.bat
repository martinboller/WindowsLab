REM net stop tiledatamodelsvc
echo "Running Sysprep and shutting down"
c:\windows\system32\sysprep\sysprep.exe /generalize /mode:vm /oobe /unattend:a:\unattend.xml
shutdown /s
