Add-PSSnapin Microsoft.SharePoint.PowerShell  -EA 0
Start-SPAssignment -Global 
 
$urlWebApp = $args[0]
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$identity = "SharePoint.wsp"
$pathWspFile = "$scriptPath\$identity"
$xml = [xml](get-content "$scriptPath\SharePoint.Configuration.xml")

#Region Fonctions Externes
. ".\SharePoint.Functions.ps1"
#EndRegion

Write-Host "#### Solution deploy ####"

    
    Write-Host "[INFO] ----------------------------------------"
    Write-Host -NoNewLine "[INFO] $Identity is already installed"

    $isInstalled = Get-SPSolution | where { $_.Name -eq $identity }
    if ($isInstalled)
    {
        Write-Host -ForegroundColor Yellow "...Yes!"
        (RetractSolution $identity)
        (DeploySolution $pathWspFile $identity)
    }
    else
    {
        Write-Host -ForegroundColor Yellow "...No!"
        (DeploySolution $pathWspFile $identity)
    }

	$xml.Features.Feature | foreach {  
		EnableFeature $identity $urlWebApp $_.Name
	}
    Write-Host -NoNewline "[INFO] Installation and deployment of $Identity"
    Write-Host -ForegroundColor Green "...Done!"
