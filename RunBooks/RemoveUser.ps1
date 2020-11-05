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

$groups | ForEach-Object {
        $groupName = $_.DisplayName;
        $objectId = $_.ObjectId;
        if ($groupName -eq 'Production' ) {
            $users = Get-AzureADGroupMember -ObjectId $objectId;
            Write-Output "`nThere are total of $($users.count) users in Production group. Here is the list"
            $users.DisplayName
            foreach ($user in $users) {
                Write-Output "`nRemoving $($user.DisplayName) user from Production group";
                Remove-AzureADGroupMember -ObjectId $objectId -MemberId $($user.ObjectId) 
            }
        }
}