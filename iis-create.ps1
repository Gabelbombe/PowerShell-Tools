# --------------------------------------------------------------------
# Define the variables.
# --------------------------------------------------------------------
Param (
    [string]$InetPhysPath = $( $env:SystemDrive + "\inetpub\wwwroot" ),
    [string]$InetSiteName = $( Read-Host "Site Name" ),
    [int]$InetSitePort    = $( Read-Host "Site Port" )
)

Import-Module "WebAdministration"

# --------------------------------------------------------------------
# Check for empty.
# --------------------------------------------------------------------
if(-not($InetSiteName)) { Throw "Site name cannot be empty..." }
if(-not($InetSitePort)) { Throw "Site port cannot be empty..." }
if(-not($InetPhysPath)) { Throw "Path name cannot be empty..." }

# --------------------------------------------------------------------
# Configure and register.
# --------------------------------------------------------------------
New-Item IIS:\Sites\$InetSiteName -physicalPath $InetPhysPath -bindings @{ protocol="http";bindingInformation=":"+$InetSitePort+":"+$InetSiteName } 
Set-ItemProperty IIS:\Sites\$InetSiteName -name applicationPool -value BenAPI
Start-WebSite $InetSiteName

# --------------------------------------------------------------------
# Run.
# --------------------------------------------------------------------
$webclient = New-Object Net.WebClient 
$webclient.DownloadString("http://localhost:$InetSitePort/");

$ie = New-Object -com InternetExplorer.Application 
$ie.Visible = $true 
$ie.Navigate("http://localhost:$InetSitePort/");