$rg = "VRK-RG"
$vms =  (Get-AzVM -ResourceGroupName $rg).Name

foreach($vm in $vms) {
    Write-Host "`nChecking in $vm"
    $response = Invoke-AzVMRunCommand -ResourceGroupName $rg -VMName $vm -CommandId 'RunPowerShellScript' -ScriptPath 'C:\Users\v-ravent.FAREAST\Documents\VRK FILES DONT DELETE\Orcas Project\Powershell Scripts\git repo\RunCommandsInVM\UpdateAgent.ps1'
    $output = $response.value[0].message
    $output
}