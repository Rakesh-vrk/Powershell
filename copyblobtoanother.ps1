
New-AzResourceGroup -Name rg-eastus -location eastus

New-AzStorageAccount -ResourceGroupName rg-eastus -AccountName stcacc008 -Location eastus -SkuName Standard_ZRS -Kind StorageV2

New-AzStorageAccount -ResourceGroupName rg-eastus -AccountName stcacc009 -Location eastus -SkuName Standard_ZRS -Kind StorageV2 -AsJob

$Acccontext = Get-AzContext

azcopy.exe login --tenant-id $Acccontext.Tenant.Id

$stacc1 = Get-AzStorageAccount -StorageAccountName stcacc008 -ResourceGroupName rg-eastus
$stacc2 = Get-AzStorageAccount -StorageAccountName stcacc009 -ResourceGroupName rg-eastus

$StaccSAS1 = New-AzStorageAccountSASToken -Service Blob,File,Table,Queue -ResourceType Service,Container,Object -Permission "racwdlup" -Context $stacc1.Context

$StaccSAS2 = New-AzStorageAccountSASToken -Service Blob,File,Table,Queue -ResourceType Service,Container,Object -Permission "racwdlup" -Context $stacc2.Context

New-AzStorageContainer -Name demo -Context $stacc1.Context -Permission Container

azcopy.exe copy "C:\Users\v-ravent.FAREAST\Documents\VRK FILES DONT DELETE\Orcas Project\Powershell Scripts\git repo\RunCommandsInVM\" "$($stacc1.Context.BlobEndPoint)demo/$staccSAS1" --recursive

azcopy.exe copy "https://stcacc008.blob.core.windows.net/demo/$staccSAS1" "https://stcacc009.blob.core.windows.net/$StaccSAS2" --recursive