#Resource Group Name
$resourceGroup = "webapp"
#Location of the Resources
$location = "centralindia"
#VM Name
$vmName = "ubuntu01"

# Defining credentials
$securePassword = ConvertTo-SecureString 'Trainer@1234' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("trainer", $securePassword)

#Creating Resource Group
New-AzResourceGroup -Name $resourceGroup -Location $location

#Creating ubuntu vm
New-AzVM -ResourceGroupName $resourceGroup -Name $vmName -location $location `
         -Image UbuntuLTS -Credential $cred -OpenPorts 22

#Stopping the VM
Stop-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Force

#Generalising the VM
Set-AzVm -ResourceGroupName $resourceGroup -Name $vmName -Generalized

#Get the details of VM
$vm = Get-AzVM -Name $vmName -ResourceGroupName $resourceGroup

#Create Image Configuration
$image = New-AzImageConfig -Location $location -SourceVirtualMachineId $vm.Id 

#Image Name
$imageName = "jvm-ubuntu"

#Create New Image
New-AzImage -Image $image -ImageName $imageName -ResourceGroupName $resourceGroup

#Getting the Image details
Get-AzImage -ResourceGroupName $resourceGroup

#VM Name created from Custom Image
$vmNameFromCustom = "jvm-ubuntu01"

New-AzVM -ResourceGroupName $resourceGroup -Name $vmNameFromCustom -location $location `
         -Image $imageName -Credential $cred -OpenPorts 22

#To Remove Resource Group
#Remove-AzResourceGroup -Name myResourceGroup
