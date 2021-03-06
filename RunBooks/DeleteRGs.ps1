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

$tags = @{"env"="Test"};


$jobs = @();

$rgList = Get-AzResourceGroup
Write-Output "`nThere are total of $($rgList.count) Resource groups in subscription. Here is the list"
$rgList | Select-Object -Property ResourceGroupName

$rg = Get-AzResourceGroup -Tag $tags
Write-Output "`nThere are total of $($rg.count) Resource groups with test tag. Here is the list"
$rg | Select-Object -Property ResourceGroupName

$rg | ForEach-Object {  
        $rgname = $_.ResourceGroupName;
        Write-Output "`n*Removing $rgname resource group"
        $job = Remove-AzResourceGroup -Name $rgname -AsJob -Force;
        Write-Output "*Assigned job id $($job.Id) to remove $rgname resource group`n" ;
        $jobs += $job;
        Start-Sleep 2;
    }

foreach ($j in $jobs) {
    $wait = Wait-Job $j
    if($wait.State -eq 'Completed') {
        Write-Output "`n***Job which has Id $($j.Id) is Completed";
    } else {
        Write-Output "`n***Job which has Id $($j.Id) is Failed";
    }
}
