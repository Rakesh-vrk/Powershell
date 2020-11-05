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

<#
, "env"="test", "env"="TEST", "env"="TeST",  "env"="TesT", "env"="TEsT",
          "env"="TeSt", "env"="tesT",
          "env"="TEst", "env"="TESt",
          "env"="tEST", "env"="teST",
          "Env"="Test", "Env"="test",
          "Env"="TEST", "Env"="TeST",  
          "Env"="TesT", "Env"="TEsT",
          "Env"="TeSt", "Env"="tesT",
          "Env"="TEst", "Env"="TESt",
          "Env"="tEST", "Env"="teST",
          "ENv"="Test", "ENv"="test"
          "ENv"="TEST", "ENv"="TeST",  
          "ENv"="TesT", "ENv"="TEsT",
          "ENv"="TeSt", "ENv"="tesT",
          "ENv"="TEst", "ENv"="TESt",
          "ENv"="tEST", "ENv"="teST",
          "ENV"="Test", "ENV"="test",
          "ENV"="TEST", "ENV"="TeST",  
          "ENV"="TesT", "ENV"="TEsT",
          "ENV"="TeSt", "ENV"="tesT",
          "ENV"="TEst", "ENV"="TESt",
          "ENV"="tEST", "ENV"="teST",
          "eNV"="Test", "eNV"="test",
          "eNV"="TEST", "eNV"="TeST",  
          "eNV"="TesT", "eNV"="TEsT",
          "eNV"="TeSt", "eNV"="tesT",
          "eNV"="TEst", "eNV"="TESt",
          "eNV"="tEST", "eNV"="teST",
          "enV"="Test", "enV"="test",
          "enV"="TEST", "enV"="TeST",  
          "enV"="TesT", "enV"="TEsT",
          "enV"="TeSt", "enV"="tesT",
          "enV"="TEst", "enV"="TESt",
          "enV"="tEST", "enV"="teST",
          "eNv"="Test", "eNv"="test",
          "eNv"="TEST", "eNv"="TeST",  
          "eNv"="TesT", "eNv"="TEsT",
          "eNv"="TeSt", "eNv"="tesT",
          "eNv"="TEst", "eNv"="TESt",
          "eNv"="tEST", "eNv"="teST",
          "EnV"="Test", "EnV"="test",
          "EnV"="TEST", "EnV"="TeST",  
          "EnV"="TesT", "EnV"="TEsT",
          "EnV"="TeSt", "EnV"="tesT",
          "EnV"="TEst", "EnV"="TESt",
          "EnV"="tEST", "EnV"="teST"
          }
#>

$jobs = @();

$rgList = Get-AzResourceGroup
Write-Output "`nThere are total of $($rgList.count) Resource groups in Quadrant subscription. Here is the list"
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
