param(    
    $subscriptionId = "68561d79-60fb-4d83-9688-16314efefe17",
    $servicePrincipalId = "db583b7d-abd6-4c0c-b929-f3754baf4b31",
    $tenantId = "8b87af7d-8647-4dc7-8df4-5f69a2011bb5",
    $resourceGroupName = "Blueprint-RG",
    $blueprintName = "Blueprint_Workshop",
    $assignmentName = "Assignment_Workshop"
)
$servicePrincipalPass = Read-Host -Prompt "Provide service principal secret: "
try{
    # Authenticate to Azure
    Write-Host "Connect to azure with Service Principal"
    Clear-AzContext -Scope Process
    Clear-AzContext -Scope CurrentUser -Force -ErrorAction SilentlyContinue
    $pass = ConvertTo-SecureString $servicePrincipalPass -AsPlainText -Force
    $Credential = New-Object -TypeName pscredential -ArgumentList $servicePrincipalId, $pass    
    Connect-AzAccount -ServicePrincipal -Tenant $tenantId -Subscription $subscriptionId -Credential $Credential -Environment AzureCloud
    Set-AzContext -SubscriptionId $subscriptionId -TenantId $tenantId

    Write-Host "Getting blueprint definition..."
    $bpDefinition = Get-AzBlueprint -SubscriptionId $subscriptionId -Name $blueprintName -LatestPublished

    Write-Host "Creating hash table for parameters..."
    $bpParameters = @{
        BP_vnetName = "WORKSHOP-VNET"
        BP_nsgName = "WORKSHOP-NSG"
    }

    Write-Host "Creating hash table for ResourceGroupParameters..."
    $bpRGParameters = @{"Blueprint-RG"=@{name=$resourceGroupName}}

    $oldAssignment = Get-AzBlueprintAssignment -SubscriptionId $subscriptionId -Name $assignmentName -ErrorAction silentlycontinue

    if ($oldAssignment) {
        Write-Host "Updating existing assignment..."
        Set-AzBlueprintAssignment -Name $assignmentName -Blueprint $bpDefinition -SubscriptionId $subscriptionId -Location 'northeurope' -Parameter $bpParameters -ResourceGroupParameter $bpRGParameters
    } else {
        Write-Host "Creating new assignment..."
        New-AzBlueprintAssignment -Name $assignmentName -Blueprint $bpDefinition -SubscriptionId $subscriptionId -Location 'northeurope' -Parameter $bpParameters -ResourceGroupParameter $bpRGParameters
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