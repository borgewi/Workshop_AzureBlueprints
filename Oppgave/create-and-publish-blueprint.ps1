#############################################################
# TODO Fyll inn parametre
param(
    $subscriptionId = "",
    $blueprintName = "MyVmBlueprint",
    $servicePrincipalPass = "",
    $servicePrincipalId = "",
    $tenantId = "",
    $SourceDir = ""
)                                                       
#############################################################
try{
    Write-Host "Start login"
    $pass = ConvertTo-SecureString $servicePrincipalPass -AsPlainText -Force
    $cred = New-Object -TypeName pscredential -ArgumentList $servicePrincipalId, $pass
    Login-AzAccount -Credential $cred -ServicePrincipal -TenantId $tenantId
    Write-Host "Successfully logged in"

    Write-Host "Azure context:"
    Get-AzContext

    #############################################################
    # TODO Opprett blueprintet (importer blueprint til Azure)
    
    #############################################################   
    
    if ($?) {
        Write-Host "Imported successfully"
        #############################################################
        # TODO Publiser ny versjon av blueprintet i din subscription
        
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