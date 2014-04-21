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
[string]$InetPhysPath = $( "D:\www" )

 ## For local this is fine since we aren't using D:\
 ## [string]$InetPhysPath = $( $env:SystemDrive + "\inetpub" )

# --------------------------------------------------------------------
# Custom defined variables as stop-gate.
# --------------------------------------------------------------------
$DNSRecord = "dev1.ben.productplacement.corbis.pre"
if ([string]::Compare("Y", $(Read-Host "Use $DNSRecord as DNS? [Y\n]"), $True))
{
    [string]$DNSRecord = $( Read-Host "New DNS Record" )
}

$PoolName = "BenAPI"
if ([string]::Compare("Y", $(Read-Host "Use $PoolName as Pool? [Y\n]"), $True))
{
    [string]$PoolName = $( Read-Host "New Pool" )
}

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

    New-Item IIS:\Sites\$InetSiteName -physicalPath $WebRoot -bindings @{ protocol="http";bindingInformation="*:"+$InetSitePort+":"+$DNSRecord }
    Set-ItemProperty IIS:\Sites\$InetSiteName -Name applicationPool -Value $PoolName
    Set-Content "$WebRoot\default.htm" "Test Page: $InetSiteName"

Start-WebSite $InetSiteName

# --------------------------------------------------------------------
# Run.
# --------------------------------------------------------------------
$ie = New-Object -com InternetExplorer.Application
$ie.Visible = $true

$ie.Navigate("http://"+$DNSRecord+":"+$InetSitePort);