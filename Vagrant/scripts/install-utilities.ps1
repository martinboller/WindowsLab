# Purpose: Installs additional utilities, Powersploit and MimiKatz

  # Define the computer name
  $computerName = $env:computername
  $domain = "siemlab.dk"

# Import the WinRM module
Import-Module -Name Microsoft.WSMan.Management

# Define credentials
  $PlainPassword = "vagrant"
  $SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
  $adminUser = "vagrant"
  $SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
  $adCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminUser, $SecurePassword

  # Define the applications to install
  #$wingetPackages = "Microsoft.VisualStudioCode", "Microsoft.WindowsTerminal"
  
#   # Create a WinRM session to the remote machine
#   $session = New-PSSession -ComputerName $computerName -Credential $adCredential

#  foreach($packageName in $wingetPackages)
#     {
#       # Define the Winget command you want to run remotely
#       $wingetCommand = "winget install $packageName  --accept-package-agreements --accept-source-agreements --silent --disable-interactivity"        
#       # Invoke the Winget command remotely using the WinRM session
#       Invoke-Command -Session $session -ScriptBlock { Invoke-Expression $using:wingetCommand }
#     }
# # Close the WinRM session
# Remove-PSSession -Session $session

# Disable Windows Defender realtime scanning before downloading Mimikatz and drop the firewall
If ($env:computername -ilike "win1*") {

#   Invoke-Command -ComputerName $env:computername -ScriptBlock {winget install TheDocumentFoundation.LibreOffice --accept-package-agreements --accept-source-agreements --silent --disable-interactivity}
#   # Define the applications to install
#   $wingetPackages = "TheDocumentFoundation.LibreOffice", "WinRAR"
  
#   # Create a WinRM session to the remote machine
#   $session = New-PSSession -ComputerName $computerName -Credential $adCredential

#  foreach($packageName in $wingetPackages)
#     {
#       # Define the Winget command you want to run remotely
#       $wingetCommand = "winget install $packageName  --accept-package-agreements --accept-source-agreements --silent --disable-interactivity"        
#       # Invoke the Winget command remotely using the WinRM session
#       Invoke-Command -Session $session -ScriptBlock { Invoke-Expression $using:wingetCommand }
#     }
# # Close the WinRM session
# Remove-PSSession -Session $session

  # If (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender")
  # {
  #   Remove-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Recurse -Force
  # }
  # gpupdate /force | Out-String
  # Set-MpPreference -ExclusionPath C:\commander.exe, C:\Tools
  # set-MpPreference -DisableRealtimeMonitoring $true
  # Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False


  # # Purpose: Downloads and unzips a copy of the latest Mimikatz trunk
  # Write-Host "Determining latest release of Mimikatz..."
  # # GitHub requires TLS 1.2 as of 2/27
  # [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  # $tag = (Invoke-WebRequest "https://api.github.com/repos/gentilkiwi/mimikatz/releases" -UseBasicParsing | ConvertFrom-Json)[0].tag_name
  # $mimikatzDownloadUrl = "https://github.com/gentilkiwi/mimikatz/releases/download/$tag/mimikatz_trunk.zip"
  # $mimikatzRepoPath = 'C:\Users\vagrant\AppData\Local\Temp\mimikatz_trunk.zip'
  # if (-not (Test-Path $mimikatzRepoPath))
  # {
  #   Invoke-WebRequest -Uri "$mimikatzDownloadUrl" -OutFile $mimikatzRepoPath
  #   Expand-Archive -path "$mimikatzRepoPath" -destinationpath 'c:\Tools\Mimikatz' -Force
  # }
  # else
  # {
  #   Write-Host "Mimikatz was already installed. Moving On."
  # }

  # # Download and unzip a copy of PowerSploit
  # Write-Host "Downloading Powersploit..."
  # # GitHub requires TLS 1.2 as of 2/27
  # [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  # $powersploitDownloadUrl = "https://github.com/PowerShellMafia/PowerSploit/archive/master.zip"
  # $powersploitRepoPath = "C:\Users\vagrant\AppData\Local\Temp\powersploit.zip"
  # if (-not (Test-Path $powersploitRepoPath)) {
  #   Invoke-WebRequest -Uri "$powersploitDownloadUrl" -OutFile $powersploitRepoPath
  #   Expand-Archive -path "$powersploitRepoPath" -destinationpath 'c:\Tools\PowerSploit' -Force
  #   Copy-Item "c:\Tools\PowerSploit\PowerSploit-master\*" "$Env:windir\System32\WindowsPowerShell\v1.0\Modules" -Recurse -Force
  # } else {
  #   Write-Host "PowerSploit was already installed. Moving On."
  # }
}

Write-Host "Utilities installation complete!"
