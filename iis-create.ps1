# --------------------------------------------------------------------
# Checking Execution Policy
# --------------------------------------------------------------------
#$Policy = "Unrestricted"
$Policy = "RemoteSigned"
If ((get-ExecutionPolicy) -ne $Policy) {
  Write-Host "Script Execution is disabled. Enabling it now"
  Set-ExecutionPolicy $Policy -Force
  Write-Host "Please Re-Run this script in a new powershell enviroment"
  Exit
}

# --------------------------------------------------------------------
# Define the variables.
# --------------------------------------------------------------------
[string]$InetSiteName = $( Read-Host "Site Name" )
[int]$InetSitePort    = $( Read-Host "Site Port" )
[string]$InetPhysPath = $( $env:SystemDrive + "\inetpub" )

$PoolName = "BenAPI"

# --------------------------------------------------------------------
# Loading IIS Modules
# --------------------------------------------------------------------
Import-Module "WebAdministration"

# --------------------------------------------------------------------
# Test or Create App Pool
# --------------------------------------------------------------------
if (!(Test-Path "IIS:\AppPools\$PoolName" -pathType container))
{
    # Create pool
    $appPool = New-Item "IIS:\AppPools\$PoolName"
    $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value "v4.0"
}

# --------------------------------------------------------------------
# Configure and register.
# --------------------------------------------------------------------
$WebRoot = New-Item "$InetPhysPath\$InetSiteName" -type Directory
New-Item IIS:\Sites\$InetSiteName -physicalPath $WebRoot -bindings @{ protocol="http";bindingInformation="*:"+$InetSitePort+":" } 

Set-ItemProperty IIS:\Sites\$InetSiteName -name applicationPool -value BenAPI
Set-Content "$WebRoot\default.htm" "Test Page: $InetSiteName"

Start-WebSite $InetSiteName

# --------------------------------------------------------------------
# Run.
# --------------------------------------------------------------------
$ie = New-Object -com InternetExplorer.Application 
$ie.Visible = $true 
$ie.Navigate("http://localhost:$InetSitePort/");