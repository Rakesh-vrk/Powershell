$rg = "window-vm"
$vms =  (Get-AzVM -ResourceGroupName $rg).Name

foreach($vm in $vms) {
    Write-Host "`nChecking in $vm"
    $response = Invoke-AzVMRunCommand -ResourceGroupName $rg -VMName $vm -CommandId 'RunPowerShellScript' -ScriptPath 'C:\Users\vrk4c\Documents\PowerShell\Scripts\RunCommandsInVM\UpdateAgent.ps1'
    $output = $response.value[0].message
    $output
}