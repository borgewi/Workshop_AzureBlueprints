param(
    $subscriptionId = "68561d79-60fb-4d83-9688-16314efefe17",
    $blueprintName = "Blueprint_Workshop",
    $servicePrincipalId = "db583b7d-abd6-4c0c-b929-f3754baf4b31",
    $tenantId = "8b87af7d-8647-4dc7-8df4-5f69a2011bb5",
    $SourceDir = "C:\src\Workshop_AzureBlueprints\Solution"
)
$servicePrincipalPass = Read-Host -Prompt "Provide service principal secret: "

try{
    # TODO Må laste inn az-moduler for de som ikke har de fra før

    Write-Host "Start login with SPN"
    $pass = ConvertTo-SecureString $servicePrincipalPass -AsPlainText -Force
    $cred = New-Object -TypeName pscredential -ArgumentList $servicePrincipalId, $pass
    Login-AzAccount -Credential $cred -ServicePrincipal -TenantId $tenantId
    Write-Host "Successfully logged in with SPN"

    Write-Host "Azure context:"
    Get-AzContext
    
    Write-Host "Start Blueprint import"
    Import-AzBlueprintWithArtifact -Name $blueprintName -SubscriptionId $subscriptionId -InputPath $SourceDir

    if ($?) {
        Write-Host "Imported successfully"
        #############################################################
        # TODO Publiser ny versjon av blueprintet i din subscription
        $date = Get-Date -UFormat %Y%m%d.%H%M%S
        $genVersion = $date
        
        $importedBp = Get-AzBlueprint -SubscriptionId $subscriptionId -Name $blueprintName 
        Publish-AzBlueprint -Blueprint $importedBp -Version $genVersion
        #############################################################
    } else {
        throw "Failed to import successfully"
        exit 1
    }
}
catch
{ 
	if ($_.ErrorDetails.Message) {$ErrDetails = $_.ErrorDetails.Message } else {$ErrDetails = $_}
 	Write-Host "ERROR! $($ErrDetails)"
	exit 1		
}