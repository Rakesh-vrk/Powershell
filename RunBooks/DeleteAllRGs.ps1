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

$jobs = @();

$rgList = Get-AzResourceGroup | where-Object { $_.ResourceGroupName -notin 'rg-eastus' }
Write-Output "`nThere are total of $($rgList.count) Resource groups exculding rg-eastus. Here is the list"
$rgList | Select-Object -Property ResourceGroupName

$rgList | ForEach-Object {  
        $rgname = $_.ResourceGroupName;
        Write-Output "`n*Removing $rgname resource group"
        $job = Remove-AzResourceGroup -Name $rgname -AsJob -Force;
        Write-Output "*Assigned job id $($job.Id) to remove $rgname resource group`n" ;
        $jobs += $job;
        Start-Sleep 2;
    }

foreach ($j in $jobs) {
    $wait = Wait-Job -Id $j.Id
    if($wait.State -eq 'Completed') {
        Write-Output "`n***Job which has Id $($j.Id) is Completed";
        Receive-Job -Id $j.Id
    } else {
        Write-Output "`n***Job which has Id $($j.Id) is Failed";
    }
}