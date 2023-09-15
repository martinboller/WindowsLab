function Install-Winget {
    Write-Host "Install with license file"
    # get latest download url
    #$URL = "https://github.com/microsoft/winget-cli/releases/tag/v1.4.10173"
    $URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    $BUNDLE = (Invoke-WebRequest -UseBasicParsing -Uri $URL).Content | ConvertFrom-Json |
        Select-Object -ExpandProperty "assets" |
        Where-Object "browser_download_url" -Match '.msixbundle' |
        Select-Object -ExpandProperty "browser_download_url"
    $LICENSEFILE = (Invoke-WebRequest -UseBasicParsing -Uri $URL).Content | ConvertFrom-Json |
                Select-Object -ExpandProperty "assets" |
                Where-Object "browser_download_url" -Match '.xml' |
                Select-Object -ExpandProperty "browser_download_url"
        
    # download
    Invoke-WebRequest -Uri $BUNDLE -OutFile "winget-installer.msixbundle" -UseBasicParsing
    Invoke-WebRequest -Uri $LICENSEFILE -OutFile "winget-installer.license" -UseBasicParsing

    # Reinstall with license file
    Add-AppxProvisionedPackage -Online -PackagePath .\winget-installer.msixbundle -LicensePath .\winget-installer.license
}


Install-Winget

# Define computer name and domain
$computerName = "localhost" #$env:computername
$domain = "siemlab.dk"

# Define credentials
$PlainPassword = "vagrant"
$SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
$adminUser = "vagrant"
$SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
$adCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminUser, $SecurePassword

#$wingetPackages = "Microsoft.XMLNotepad"
# Define the winget commands to run after installation
$wingetPackages = ,"Microsoft.XMLNotepad"
#"source update winget --accept-source-agreements --disable-interactivity --silent --scope machine", "source update msstore", "upgrade --all --accept-source-agreements --disable-interactivity --recurse --silent --scope machine"

# Create a WinRM session to the remote machine
$session = New-PSSession -ComputerName $computerName -Credential $adCredential

foreach($packageName in $wingetPackages)
  {
    # Define the Winget command you want to run remotely
    $wingetCommand = "winget install $packageName --accept-source-agreements"        
    # Invoke the Winget command remotely using the WinRM session
    #Invoke-Command -Session $session -ScriptBlock { Invoke-Expression $using:wingetCommand }
    Invoke-Expression $wingetCommand
  }
# Close the WinRM session
Remove-PSSession -Session $session
