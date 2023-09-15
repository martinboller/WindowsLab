# Purpose: Installs WinlogBeat on the host

If (-not (Test-Path "C:\Program Files\SplunkUniversalForwarder\bin\splunk.exeC:\Program Files\Elastic\Beats")) {
  Write-Host "Installing WinLogBeat"
  Invoke-Command -ComputerName $env:computername -ScriptBlock {winget install winlogbeat --accept-package-agreements --accept-source-agreements --silent --disable-interactivity}
} Else {
  Write-Host "WinLogBeat already installed. Moving on."
}

# Configure winlogbeat


If ((Get-Service -name winlogbeat).Status -ne "Running")
{
  Start-Service winlogbeat
}
Write-Host "WinLogBeat installation complete!"
