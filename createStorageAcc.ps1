#Time when the script started
$starttime = [datetime]::UTCNow

#Location of the Resources
$locations = @("centralindia", "southindia", "westindia")

for($i=0; $i -lt 9; $i++) {

    #Resource Group Name
    $resourceGroup = "rg" + $i;
    #Location
    $location = $locations[$i%3];
    #Storage Account Name
    $storageName = "storage" + $(get-random);

    #Creating Resource Group
    New-AzResourceGroup -Name $resourceGroup -Location $location;

    #Creating storage accounts 
    $job = New-AzStorageAccount -ResourceGroupName $resourceGroup -AccountName $storageName `
                        -Location $location -SkuName "Standard_LRS" -Kind StorageV2 -AsJob;

    Start-Sleep 2;

}

wait-job $job

#Time when the script ended
$endtime = [datetime]::UTCNow

Write-output "Time taken to run the script $($($endtime - $starttime).TotalSeconds) Seconds"