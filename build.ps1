#Requires -Version 4.0

<#
.Synopsis
   This script is used to deploy a fresh install of DetectionLab

.DESCRIPTION
   This scripts runs a series of tests before running through the
   DetectionLab deployment. It checks:

   * If Packer and Vagrant are installed
   * If VirtualBox or VMWare are installed
   * If the proper vagrant plugins are available
   * Various aspects of system health

   Post deployment it also verifies that services are installed and
   running.

   If you encounter issues, feel free to open an issue at
   https://github.com/clong/DetectionLab/issues

.PARAMETER ProviderName
  The Hypervisor you're using for the lab. Valid options are 'virtualbox' or 'vmware_workstation'

.PARAMETER PackerPath
  The full path to the packer executable. Default is C:\Hashicorp\packer.exe

.PARAMETER VagrantOnly
  This switch skips building packer boxes and instead downloads from www.detectionlab.network

.EXAMPLE
  build.ps1 -ProviderName virtualbox

  This builds the DetectionLab using virtualbox and the default path for packer (C:\Hashicorp\packer.exe)
.EXAMPLE
  build.ps1 -ProviderName vmware_workstation -PackerPath 'C:\packer.exe'

  This builds the DetectionLab using Vmware and sets the packer path to 'C:\packer.exe'
.EXAMPLE
  build.ps1 -ProviderName vmware_workstation -VagrantOnly

  This command builds the DetectionLab using vmware and skips the packer process, downloading the boxes instead.
#>

[cmdletbinding()]
Param(
  # Vagrant provider to use.
  [ValidateSet('virtualbox', 'vmware_workstation')]
  [string]$ProviderName,
  [string]$PackerPath = 'C:\Hashicorp\packer.exe',
  [switch]$VagrantOnly
)

$DL_DIR = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$LAB_HOSTS = ('logger', 'dc', 'wef', 'win10')

# Register-EngineEvent PowerShell.Exiting -SupportEvent -Action {
#   Set-Location $DL_DIR
# }

# Register-ObjectEvent -InputObject ([System.Console]) -EventName CancelKeyPress -Action {
#   Set-Location $DL_DIR
# }

function install_checker {
  param(
    [string]$Name
  )
  $results = Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' | Select-Object DisplayName
  $results += Get-ItemProperty 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | Select-Object DisplayName

  forEach ($result in $results) {
    if ($result -like "*$Name*") {
      return $true
    }
  }
  return $false
}

function check_packer {
  #Check for packer at $PackerPath
  if (!(Test-Path $PackerPath)) {
    Write-Error "Packer not found at $PackerPath"
    Write-Output 'Re-run the script setting the PackerPath parameter to the location of packer'
    Write-Output "Example: build.ps1 -PackerPath 'C:\packer.exe'"
    Write-Output 'Exiting..'
    break
  }
}
function check_vagrant {
  # Check if vagrant is in path
  try {
    Get-Command vagrant.exe -ErrorAction Stop | Out-Null
  }
  catch {
    Write-Error 'Vagrant was not found. Please correct this before continuing.'
    break
  }

  # Check Vagrant version >= 2.0.0
  [System.Version]$vagrant_version = $(vagrant --version).Split(' ')[1]
  [System.Version]$version_comparison = 2.0.0

  if ($vagrant_version -lt $version_comparison) {
    Write-Warning 'It is highly recommended to use Vagrant 2.0.0 or above before continuing'
  }
}

# Returns false if not installed or true if installed
function check_virtualbox_installed {
  Write-Verbose '[check_virtualbox_installed] Running..'
  if (install_checker -Name "VirtualBox") {
    Write-Verbose '[check_virtualbox_installed] Virtualbox found.'
    return $true
  }
  else {
    Write-Verbose '[check_virtualbox_installed] Virtualbox not found.'
    return $false
  }
}
function check_vmware_workstation_installed {
  Write-Verbose '[check_vmware_workstation_installed] Running..'
  if (install_checker -Name "VMWare Workstation") {
    Write-Verbose '[check_vmware_workstation_installed] Vmware found.'
    return $true
  }
  else {
    Write-Verbose '[check_vmware_workstation_installed] Vmware not found.'
    return $false
  }
}

function check_vmware_vagrant_plugin_installed {
  Write-Verbose '[check_vmware_vagrant_plugin_installed] Running..'
  if (vagrant plugin list | Select-String 'vagrant-vmware-workstation') {
    Write-Verbose '[check_vmware_vagrant_plugin_installed] VMware vagrant plugin found.'
    return $true
  }
  else {
    Write-Host 'VMWare Workstation is installed, but the Vagrant plugin is not.'
    Write-Host 'Visit https://www.vagrantup.com/vmware/index.html#buy-now for more information on how to purchase and install it'
    Write-Host 'VMWare Workstation will not be listed as a provider until the Vagrant plugin has been installed.'
    return $false
  }
}

function list_providers {
  [cmdletbinding()]
  param()

  Write-Host 'Available Providers: '
  if (check_virtualbox_installed) {
    Write-Host '[*] virtualbox'
  }
  if (check_vmware_workstation_installed) {
    if (check_vmware_vagrant_plugin_installed) {
      Write-Host '[*] vmware_workstation'
    }
  }
  if ((-Not (check_virtualbox_installed)) -and (-Not (check_vmware_workstation_installed))) {
    Write-Error 'You need to install a provider such as VirtualBox or VMware Workstation to continue.'
    break
  }
  while (-Not ($ProviderName -eq 'virtualbox' -or $ProviderName -eq 'vmware_workstation')) {
    $ProviderName = Read-Host 'Which provider would you like to use?'
    Write-Debug "ProviderName = $ProviderName"
    if (-Not ($ProviderName -eq 'virtualbox' -or $ProviderName -eq 'vmware_workstation')) {
      Write-Error "Please choose a valid provider. $ProviderName is not a valid option"
    }
  }
  return $ProviderName
}

function download_boxes {
  Write-Verbose '[download_boxes] Running..'
  if ($PackerProvider -eq 'virtualbox') {
    $win10Hash = 'd6304f01caa553a18022ea7b5a73ad0d'
    $win2016Hash = 'b59cf23dfbcdb63c0dc8a98fbc564451'
  }
  if ($PackerProvider -eq 'vmware') {
    $win10Hash = '4355e9758a862a6f6349e31fdc3a6078'
    $win2016Hash = '249fc2472849582d8b736cdabaf0eceb'
  }

  $win10Filename = "windows_10_$PackerProvider.box"
  $win2016Filename = "windows_2016_$PackerProvider.box"

  $wc = New-Object System.Net.WebClient
  Write-Verbose "[download_boxes] Downloading $win10Filename"
  $wc.DownloadFile("https://www.detectionlab.network/$win10Filename", "$DL_DIR\Boxes\$win10Filename")
  Write-Verbose "[download_boxes] Downloading $win2016Filename"
  $wc.DownloadFile("https://www.detectionlab.network/$win2016Filename", "$DL_DIR\Boxes\$win2016Filename")
  $wc.Dispose()

  if (-Not (Test-Path "$DL_DIR\Boxes\$win2016Filename")) {
    Write-Error 'Windows 2016 box is missing from the Boxes directory. Qutting.'
    break
  }
  if (-Not (Test-Path "$DL_DIR\Boxes\$win10Filename")) {
    Write-Error 'Windows 10 box is missing from the Boxes directory. Qutting.'
    break
  }

  Write-Verbose "[download_boxes] Getting filehash for: $win10Filename"
  $win10Filehash = (Get-FileHash -Path "$DL_DIR\Boxes\$win10Filename" -Algorithm MD5).Hash
  Write-Verbose "[download_boxes] Getting filehash for: $win2016Filename"
  $win2016Filehash = (Get-FileHash -Path "$DL_DIR\Boxes\$win2016Filename" -Algorithm MD5).Hash

  Write-Verbose '[download_boxes] Checking Filehashes..'
  if ($win10hash -ne $win10Filehash) {
    Write-Error 'Hash mismatch on windows_10_virtualbox.box'
    break
  }
  if ($win2016hash -ne $win2016Filehash) {
    Write-Error 'Hash mismatch on windows_2016_virtualbox.box'
    break
  }
  Write-Verbose '[download_boxes] Finished.'
}

function preflight_checks {
  Write-Verbose '[preflight_checks] Running..'
  # Check to see that no boxes exist
  if (-Not ($VagrantOnly)) {
    Write-Verbose '[preflight_checks] Checking if packer is installed'
    check_packer

    # Check Packer Version against known bad
    Write-Verbose '[preflight_checks] Checking for bad packer version..'
    [System.Version]$PackerVersion = $(& $PackerPath "--version")
    [System.Version]$PackerKnownBad = 1.1.2

    if ($PackerVersion -eq $PackerKnownBad) {
      Write-Error 'Packer 1.1.2 is not supported. Please upgrade to a newer version and see https://github.com/hashicorp/packer/issues/5622 for more information.'
      break
    }
  }
  Write-Verbose '[preflight_checks] Checking if vagrant is installed'
  check_vagrant

  Write-Verbose '[preflight_checks] Checking for pre-existing boxes..'
  if ((Get-ChildItem "$DL_DIR\Boxes\*.box").Count -gt 0) {
    Write-Host 'You seem to have at least one .box file present in the Boxes directory already. If you would like fresh boxes downloaded, please remove all files from the Boxes directory and re-run this script.'
  }

  # Check to see that no vagrant instances exist
  Write-Verbose '[preflight_checks] Checking for vagrant instances..'
  $CurrentDir = Get-Location
  Set-Location "$DL_DIR\Vagrant"
  if (($(vagrant status) | Select-String -Pattern "not[ _]created").Count -ne 4) {
    Write-Error 'You appear to have already created at least one Vagrant instance. This script does not support already created instances. Please either destroy the existing instances or follow the build steps in the README to continue.'
    break
  }
  Set-Location $CurrentDir

  # Check available disk space. Recommend 80GB free, warn if less
  Write-Verbose '[preflight_checks] Checking disk space..'
  $drives = Get-PSDrive | Where-Object {$_.Provider -like '*FileSystem*'}
  $drivesList = @()

  forEach ($drive in $drives) {
    if ($drive.free -lt 80GB) {
      $DrivesList = $DrivesList + $drive
    }
  }

  if ($DrivesList.Count -gt 0) {
    Write-Output "The following drives have less than 80GB of free space. They should not be used for deploying DetectionLab"
    forEach ($drive in $DrivesList) {
      Write-Output "[*] $($drive.Name)"
    }
    Write-Output "You can safely ignore this warning if you are deploying DetectionLab to a different drive."
  }

  # Ensure the vagrant-reload plugin is installed
  Write-Verbose '[preflight_checks] Checking if vagrant-reload is installed..'
  if (-Not (vagrant plugin list | Select-String 'vagrant-reload')) {
    Write-Output 'The vagrant-reload plugin is required and not currently installed. This script will attempt to install it now.'
    (vagrant plugin install 'vagrant-reload')
    if ($LASTEXITCODE -ne 0) {
      Write-Error 'Unable to install the vagrant-reload plugin. Please try to do so manually and re-run this script.'
      break
    }
  }
  Write-Verbose '[preflight_checks] Finished.'
}

function packer_build_box {
  param(
    [string]$Box
  )

  Write-Verbose "[packer_build_box] Running for $Box"
  $CurrentDir = Get-Location
  Set-Location "$DL_DIR\Packer"
  Write-Output "Using Packer to build the $BOX Box. This can take 90-180 minutes depending on bandwidth and hardware."
  &$PackerPath @('build', "--only=$PackerProvider-iso", "$box.json")
  Write-Verbose "[packer_build_box] Finished for $Box. Got exit code: $LASTEXITCODE"

  if ($LASTEXITCODE -ne 0) {
    Write-Error "Something went wrong while attempting to build the $BOX box."
    Write-Output "To file an issue, please visit https://github.com/clong/DetectionLab/issues/"
    break
  }
  Set-Location $CurrentDir
}

function move_boxes {
  Write-Verbose "[move_boxes] Running.."
  Move-Item -Path $DL_DIR\Packer\*.box -Destination $DL_DIR\Boxes
  if (-Not (Test-Path "$DL_DIR\Boxes\windows_10_$PackerProvider.box")) {
    Write-Error "Windows 10 box is missing from the Boxes directory. Qutting."
    break
  }
  if (-Not (Test-Path "$DL_DIR\Boxes\windows_2016_$PackerProvider.box")) {
    Write-Error "Windows 2016 box is missing from the Boxes directory. Qutting."
    break
  }
  Write-Verbose "[move_boxes] Finished."
}

function vagrant_up_host {
  param(
    [string]$VagrantHost
  )
  Write-Verbose "[vagrant_up_host] Running for $VagrantHost"
  Write-Host "Attempting to bring up the $VagrantHost host using Vagrant"
  $CurrentDir = Get-Location
  Set-Location "$DL_DIR\Vagrant"
  &vagrant.exe @('up', $VagrantHost, '--provider', "$ProviderName")
  Set-Location $CurrentDir
  Write-Verbose "[vagrant_up_host] Finished for $VagrantHost. Got exit code: $LASTEXITCODE"
  return $LASTEXITCODE
}

function vagrant_reload_host {
  param(
    [string]$VagrantHost
  )
  Write-Verbose "[vagrant_reload_host] Running for $VagrantHost"
  $CurrentDir = Get-Location
  Set-Location "$DL_DIR\Vagrant"
  &vagrant.exe @('reload', $VagrantHost, '--provision') | Out-Null
  Set-Location $CurrentDir
  Write-Verbose "[vagrant_reload_host] Finished for $VagrantHost. Got exit code: $LASTEXITCODE"
  return $LASTEXITCODE
}

function download {
  param(
    [string]$URL,
    [string]$PatternToMatch
  )
  Write-Verbose "[download] Running for $URL, looking for $PatternToMatch"
  [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
  [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

  $wc = New-Object System.Net.WebClient
  $result = $wc.DownloadString($URL)
  if ($result -like "*$PatternToMatch*") {
    Write-Verbose "[download] Found $PatternToMatch at $URL"
    return $true
  }
  else {
    Write-Verbose "[download] Could not find $PatternToMatch at $URL"
    return $false
  }
}

function post_build_checks {

  Write-Verbose '[post_build_checks] Running Caldera Check.'
  $CALDERA_CHECK = download -URL 'https://192.168.56.5:8888' -PatternToMatch '<title>CALDERA</title>'
  Write-Verbose "[post_build_checks] Cladera Result: $CALDERA_CHECK"

  Write-Verbose '[post_build_checks] Running Splunk Check.'
  $SPLUNK_CHECK = download -URL 'https://192.168.56.5:8000/en-US/account/login?return_to=%2Fen-US%2F' -PatternToMatch 'This browser is not supported by Splunk'
  Write-Verbose "[post_build_checks] Splunk Result: $SPLUNK_CHECK"

  Write-Verbose '[post_build_checks] Running Fleet Check.'
  $FLEET_CHECK = download -URL 'https://192.168.56.5:8412' -PatternToMatch 'Kolide Fleet'
  Write-Verbose "[post_build_checks] Fleet Result: $FLEET_CHECK"

  if ($CALDERA_CHECK -eq $false) {
    Write-Warning 'Caldera failed post-build tests and may not be functioning correctly.'
  }
  if ($SPLUNK_CHECK -eq $false) {
    Write-Warning 'Splunk failed post-build tests and may not be functioning correctly.'
  }
  if ($FLEET_CHECK -eq $false) {
    Write-Warning 'Fleet failed post-build tests and may not be functioning correctly.'
  }
}


# If no ProviderName was provided, get a provider
if ($ProviderName -eq $Null -or $ProviderName -eq "") {
  $ProviderName = list_providers
}

# Set Provider variable for use deployment functions
if ($ProviderName -eq 'vmware_workstation') {
  $PackerProvider = 'vmware'
}
else {
  $PackerProvider = 'virtualbox'
}


# Run check functions
preflight_checks

# Build Packer Boxes
if ($VagrantOnly) {
  download_boxes
}
else {
  packer_build_box -Box 'windows_2016'
  packer_build_box -Box 'windows_10'
  # Move Packer Boxes
  move_boxes
}

# Vagrant up each box and attempt to reload one time if it fails
forEach ($VAGRANT_HOST in $LAB_HOSTS) {
  Write-Verbose "[main] Running vagrant_up_host for: $VAGRANT_HOST"
  $result = vagrant_up_host -VagrantHost $VAGRANT_HOST
  Write-Verbose "[main] vagrant_up_host finished. Exitcode: $result"
  if ($result -eq '0') {
    Write-Output "Good news! $VAGRANT_HOST was built successfully!"
  }
  else {
    Write-Warning "Something went wrong while attempting to build the $VAGRANT_HOST box."
    Write-Output "Attempting to reload and reprovision the host..."
    Write-Verbose "[main] Running vagrant_reload_host for: $VAGRANT_HOST"
    $retryResult = vagrant_reload_host -VagrantHost $VAGRANT_HOST
    if ($retryResult -ne 0) {
      Write-Error "Failed to bring up $VAGRANT_HOST after a reload. Exiting"
      break
    }
  }
  Write-Verbose "[main] Finished for: $VAGRANT_HOST"
}


Write-Verbose "[main] Running post_build_checks"
post_build_checks
Write-Verbose "[main] Finished post_build_checks"
