$rg = "rg-eastus"

New-AzResourceGroup -Name $rg -location eastus

New-AzStorageAccount -ResourceGroupName $rg -AccountName stcacc008 -Location eastus -SkuName Standard_ZRS -Kind StorageV2

New-AzStorageAccount -ResourceGroupName $rg -AccountName stcacc009 -Location eastus -SkuName Standard_ZRS -Kind StorageV2 -AsJob

$Acccontext = Get-AzContext

.\azcopy.exe login --tenant-id $Acccontext.Tenant.Id

$stacc1 = Get-AzStorageAccount -StorageAccountName stcacc008 -ResourceGroupName $rg
$stacc2 = Get-AzStorageAccount -StorageAccountName stcacc009 -ResourceGroupName $rg

$StaccSAS1 = New-AzStorageAccountSASToken -Service Blob,File,Table,Queue -ResourceType Service,Container,Object -Permission "racwdlup" -Context $stacc1.Context

$StaccSAS2 = New-AzStorageAccountSASToken -Service Blob,File,Table,Queue -ResourceType Service,Container,Object -Permission "racwdlup" -Context $stacc2.Context

$container= 'scripts'

New-AzStorageContainer -Name $container -Context $stacc1.Context -Permission Container

.\azcopy.exe copy "C:\Users\vrk4c\Documents\PowerShell\Scripts\RunCommandsInVM\" "$($stacc1.Context.BlobEndPoint)$container/$staccSAS1" --recursive

.\azcopy.exe copy "$($stacc1.Context.BlobEndPoint)$container/$staccSAS1" "https://stcacc009.blob.core.windows.net/$StaccSAS2" --recursive

Get-AzResource -ResourceGroupName $rg | foreach { Remove-AzResource -ResourceGroupName $rg -ResourceName $_.Name -ResourceType $_.ResourceType -AsJob -Force }