#Time when the script started
$starttime = [datetime]::UTCNow

#Location of the Resources
$locations = @("centralindia", "southindia", "westindia")

for($i=0; $i -lt 9; $i++) {

    #Resource Group Name
    $resourceGroup = "rg" + $i;
    #Location
    $location = $locations[$i%3];
    #VM Name
    $vmName = "ubuntu" + $i;
    #Storage Account Name
    $storageName = "storage" + $(get-random);

    #Creating Resource Group
    New-AzResourceGroup -Name $resourceGroup -Location $location

    # Defining credentials
    $securePassword = ConvertTo-SecureString 'Trainer@1234' -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ("trainer", $securePassword)

    #Creating ubuntu vm
    New-AzVM -ResourceGroupName $resourceGroup -Name $vmName -location $location `
            -Image UbuntuLTS -Credential $cred -OpenPorts 22 

    #Creating storage accounts 
    New-AzStorageAccount -ResourceGroupName $resourceGroup -AccountName $storageName `
                        -Location $location -SkuName "Standard_LRS" -Kind StorageV2 

}

$endtime = [datetime]::UTCNow
Write-output "Time taken to run the script $($($endtime - $starttime).TotalSeconds) Seconds"
