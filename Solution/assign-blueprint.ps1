param(    
    [Parameter(Mandatory=$true)]$managementGroupId,
    [Parameter(Mandatory=$true)]$blueprintName,
    [Parameter(Mandatory=$true)]$subscriptionId,
    [Parameter(Mandatory=$true)]$applicationId,
    [Parameter(Mandatory=$true)]$tenantId,
    [Parameter(Mandatory=$true)]$servicePrincipalPass,    
    [Parameter(Mandatory=$true)]$keyVaultId,
    $secretName = "$($env:SECRETNAME)",
    $username = "$($env:USERNAME)",
    $principalId = "$($env:PRINCIPALID)",
    $devEnvNumber = "$($env:DEVENVNUMBER)",
    $resourceGroupName = "BW-Blueprint-Rg-" + $devEnvNumber,
    $assignmentName = "SLV_SAFEST_BP_ASSIGNMENT_DEV_" + $devEnvNumber
)

try{
    # Install Az Module        
    if (-not (Get-Module -Name Az)) {
        Write-Information "Module 'Az' is missing. Installing 'Az' ..."
        Install-Module -Name Az -Repository PSGallery -AllowClobber -Force
    }
    
    # Install Az.Blueprint Module        
    if (-not (Get-Module -Name Az.Blueprint)) {
        Write-Information "Module 'Az.Blueprint' is missing. Installing 'Az.Blueprint' ..."
        Install-Module -Name Az.Blueprint -AllowClobber -Force
    }

    # Authenticate to Azure
    Write-Host "Connect to azure with Service Principal"
    Clear-AzContext -Scope Process
    Clear-AzContext -Scope CurrentUser -Force -ErrorAction SilentlyContinue
    $pass = ConvertTo-SecureString $servicePrincipalPass -AsPlainText -Force
    $Credential = New-Object -TypeName pscredential -ArgumentList $applicationId, $pass    
    Connect-AzAccount -ServicePrincipal -Tenant $tenantId -Subscription $subscriptionId -Credential $Credential -Environment AzureCloud
    Set-AzContext -SubscriptionId $subscriptionId -TenantId $tenantId

    Write-Host "Getting blueprint definition..."
    $bpDefinition = Get-AzBlueprint -ManagementGroupId $managementGroupId -Name $blueprintName -LatestPublished

    Write-Host "Creating hash table for parameters..."
    $bpParameters = @{
        SLV_SAFEST_adminUsername = $username
        SLV_SAFEST_virtualMachineName = "SAFEST-VM-" + $devEnvNumber
        SLV_SAFEST_networkInterfacesName = "SAFEST-NIC-" + $devEnvNumber
        SLV_SAFEST_pipName = "SAFEST-PIP-" + $devEnvNumber
        SLV_SAFEST_vnetName = "SLV-SAFEST-VNET-DEV-CLIENT-" + $devEnvNumber
        principalId= $principalId
        SLV_SAFEST_storageAccountName= "safestdevstorageacc" + $devEnvNumber
        SLV_SAFEST_devEnvNumber = $devEnvNumber
    }

    # Secure parameters used to create os profile for virtual machine
    $secureParams = @{SLV_SAFEST_adminPassword=
        @{keyVaultId= $keyVaultId;
        secretName= $secretName}
    }

    Write-Host "Creating hash table for ResourceGroupParameters..."
    $bpRGParameters = @{"BW-Blueprint-Rg"=@{name=$resourceGroupName}}

    $oldAssignment = Get-AzBlueprintAssignment -SubscriptionId $subscriptionId -Name $assignmentName -ErrorAction silentlycontinue

    if ($oldAssignment) {
        Write-Host "Updating existing assignment..."
        Set-AzBlueprintAssignment -Name $assignmentName -Blueprint $bpDefinition -SubscriptionId $subscriptionId -Location 'northeurope' -Parameter $bpParameters -SecureStringParameter $secureParams -ResourceGroupParameter $bpRGParameters
    } else {
        Write-Host "Creating new assignment..."
        New-AzBlueprintAssignment -Name $assignmentName -Blueprint $bpDefinition -SubscriptionId $subscriptionId -Location 'northeurope' -Parameter $bpParameters -SecureStringParameter $secureParams -ResourceGroupParameter $bpRGParameters
    }

    # Check the status of the blueprint assignment
    $assignment = Get-AzBlueprintAssignment -Subscription $subscriptionId -Name $assignmentName
    $counter = 0 

    while (($assignment.ProvisioningState -ne "Succeeded") -and ($assignment.ProvisioningState -ne "Failed")) {
        Write-Host $assignment.ProvisioningState
        Start-Sleep -Seconds 5
        $assignment = Get-AzBlueprintAssignment -Subscription $subscriptionId -Name $assignmentName
        $counter++
    }
    # Take action based on terminal assignment state
    if ($assignment.ProvisioningState -eq "Succeeded") {
        Write-Host "Success"
    } elseif ($assignment.provisioningState -eq "Failed") {
        Write-Host "Failure message"
        Write-Host $assignment | Select-Object
        throw "Assignment failed to deploy"
        exit 1
    } else {
        throw "Unhandled terminal state for assignment: {0}" -f $assignment.ProvisioningState 
        exit 1
    }
}
catch
{ 
	if ($_.ErrorDetails.Message) {$ErrDetails = $_.ErrorDetails.Message } else {$ErrDetails = $_}
 	Write-Host "ERROR! $($ErrDetails)"
	exit 1		
}