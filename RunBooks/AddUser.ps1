$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    Connect-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

 Connect-AzureAD -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint

$groups = Get-AzureADGroup 

$users = @();
$ProdObjectId = "";

$groups | ForEach-Object {
    $groupName = $_.DisplayName;
    if ($groupName -eq 'ProdUsers' ) {
        $objectId = $_.ObjectId;
        $users = Get-AzureADGroupMember -ObjectId $objectId;
    }
    if ($groupName -eq 'Production' ) {
        $ProdObjectId = $_.ObjectId;
    }
}

Write-Output "`n$($users.count) users have to be added from ProdUsers group to Production group";

foreach ($user in $users) {
    Write-Output "`nAdding $($user.DisplayName) user to Production group";
    Add-AzureADGroupMember -ObjectId $ProdObjectId -RefObjectId $($user.ObjectId) 
}