# 
# Functions for SharePoint Solution Deploy
#

<# 
 .SYNOPSIS 
     Use this fonction to wait until the job is running (Timer)
 .DESCRIPTION 
     It checks that there is no job with the name of the current solution
 .PARAMETER identity
        
 .NOTES 
     
 .EXAMPLE 
     
  #>
function WaitForJobToFinish([string]$identity)
{   
    $job = Get-SPTimerJob | ?{ $_.Name -like "*solution-deployment*$identity*" }
    $maxwait = 30
    $currentwait = 0

    if (!$job)
    {
        Write-Host -f Red '[ERREUR] Timer not found. Please check service'
    }
    else
    {
        $jobName = $job.Name
        Write-Host -NoNewLine "[JOB] Waiting for the end of the execution $jobName"        
        while (($currentwait -lt $maxwait))
        {
            Write-Host -f Green -NoNewLine .
            $currentwait = $currentwait + 1
            Start-Sleep -Seconds 2
            if (!(Get-SPTimerJob $jobName)){
                break;
            }
        }
        Write-Host  -f Green "...Done!"
    }
}

<# 
 .SYNOPSIS 
     Use this fonction to uninstall solution
 .DESCRIPTION 
     It uninstalls and removes the solution definitly
 .PARAMETER identity
        
 .NOTES 
     
 .EXAMPLE 
     
  #>
function RetractSolution([string]$identity)
{
	$solution = Get-SPSolution | where { $_.Name -match $identity }
	
	Write-Host -NoNewLine "[UNINSTALL] Uninstall solution"        
	Uninstall-SPSolution -identity $identity -Confirm:$false    
	Write-Host -f Green "...Done!"
	
	WaitForJobToFinish
  
	Write-Host -NoNewLine  '[REMOVE] Remove solution:' $identity
    Remove-SPSolution -Identity $identity -Confirm:$false
    Write-Host -f Green "...Done!"
}

<# 
 .SYNOPSIS 
     Use this function to enable the features that are contained in the WSP
 .DESCRIPTION 
 .PARAMETER identity
 .PARAMETER urlWebApp
 .PARAMETER featureName
 .NOTES 
 .EXAMPLE 
     
  #>
function EnableFeature([string]$identity, [string]$urlWebApp, [string]$featureName)
{
	Enable-SPFeature -Identity "SharePoint_$featureName" -url $urlWebApp -force
	Write-Host -NoNewLine "[ACTIVATION] Feature activation:" $featureName   
    Write-Host -f Green "...Done!"
}

<# 
 .SYNOPSIS 
     Use this function to deploy solution
 .DESCRIPTION 
 .PARAMETER identity
 .PARAMETER pathWspFile
 .NOTES 
     Requires : PowerShell V2 
 .EXAMPLE 
     
  #>
function DeploySolution([string]$pathWspFile, [string]$identity)
{
    Write-Host -NoNewLine "[DEPLOY] Adding of the solution:" $identity
    Add-SPSolution $pathWspFile
    Write-Host -f Green "...Done!"

    $solution = Get-SPSolution | where { $_.Name -match $identity }
          
	Write-Host -NoNewLine "[DEPLOY] Deployment of $identity"    
	Install-SPSolution -Identity $identity -GACDeployment
    
    Write-Host -f Green "...Done!"

    WaitForJobToFinish
}
