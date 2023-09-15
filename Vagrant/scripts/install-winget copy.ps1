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

function Install-Package {
        param (
            [string]$PackageFamilyName
        )
    
        Write-Host "Querying latest $PackageFamilyName version and its dependencies..."
        $response = Invoke-WebRequest `
            -Uri "https://store.rg-adguard.net/api/GetFiles" `
            -Method "POST" `
            -ContentType "application/x-www-form-urlencoded" `
            -Body "type=PackageFamilyName&url=$PackageFamilyName&ring=RP&lang=en-US" -UseBasicParsing
    
        Write-Host "Parsing response..."
        $regex = '<td><a href=\"([^\"]*)\"[^\>]*\>([^\<]*)<\/a>'
        $packages = (Select-String $regex -InputObject $response -AllMatches).Matches.Groups
    
        $result = $true
        for ($i = $packages.Count - 1; $i -ge 0; $i -= 3) {
            $url = $packages[$i - 1].Value;
            $name = $packages[$i].Value;
            $extCheck = @(".appx", ".appxbundle", ".msix", ".msixbundle") | % { $x = $false } { $x = $x -or $name.EndsWith($_) } { $x }
            $archCheck = @("x64", "neutral") | % { $x = $false } { $x = $x -or $name.Contains("_$($_)_") } { $x }
    
            if ($extCheck -and $archCheck) {
                # Skip if package already exists on system
                $currentPackageFamilyName = (Select-String "^[^_]+" -InputObject $name).Matches.Value
                $installedVersion = (Get-AppxPackage "$currentPackageFamilyName*").Version
                $latestVersion = (Select-String "_(\d+\.\d+.\d+.\d+)_" -InputObject $name).Matches.Value
                if ($installedVersion -and ($installedVersion -ge $latestVersion)) {
                    Write-Host "${currentPackageFamilyName} is already installed, skipping..." -ForegroundColor "Yellow"
                    continue
                }
    
                try {
                    Write-Host "Downloading package: $name"
                    $tempPath = "$(Get-Location)\$name"
                    Invoke-WebRequest -Uri $url -Method Get -OutFile $tempPath
                    Add-AppxProvisionedPackage -Online -PackagePath $tempPath
                    #Add-AppxPackage -Online -Path $tempPath
                    Write-Host "Successfully installed:" $name
                } catch {
                    $result = $false
                }
            }
        }
    
        return $result
    }
    
    function Install-Package-With-Retry {
        param (
            [string]$PackageFamilyName,
            [int]$RetryCount
        )
    
        for ($t = 0; $t -le $RetryCount; $t++) {
            Write-Host "Attempt $($t + 1) out of $RetryCount..." -ForegroundColor "Cyan"
            if (Install-Package $PackageFamilyName) {
                return $true
            }
        }
    
        return $false
    }
            
        # Retry 3 times because we don't know dependency relationships
        
        #$result = @("Microsoft.DesktopAppInstaller_8wekyb3d8bbwe") | % { $x = $true } { $x = $x -and (Install-Package-With-Retry $_ 3) } { $x }

        # Test if winget has been successfully deployed
        #if ($result -and (Test-Path -Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe")) {
        #        Write-Host "winget successfully installed" -ForegroundColor "Green"
        #} else {
        #        Write-Host "Failed to install winget. Please check your logs" -ForegroundColor "Red"
        #}


        #for ($t = 0; $t -le $RetryCount; $t++) {
        #        Write-Host "Attempt $($t + 1) out of $RetryCount..." -ForegroundColor "Cyan"
        #        if (Install-Package $PackageFamilyName) {
        #        return $true
        #        }
        #}


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
