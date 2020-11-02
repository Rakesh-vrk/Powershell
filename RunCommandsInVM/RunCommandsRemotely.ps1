$vms =  ((Get-AzVM -ResourceGroupName "VRK-RG") | where-object { $_.OSProfile.WindowsConfiguration.ProvisionVMAgent -eq $True } ).Name

foreach($vm in $vms) {

    $response = Invoke-AzVMRunCommand -ResourceGroupName 'VRK-RG' -VMName $vm -CommandId 'RunPowerShellScript' -ScriptPath 'C:\Users\v-ravent.FAREAST\Documents\VRK FILES DONT DELETE\Orcas Project\Powershell Scripts\git repo\RunCommandsInVM\WinAgent.ps1'

    $output = $response.value[0].message

    foreach ($string in $($output.Split("`n"))) {
        if($string -match '\w' -and !($string.startswith('Name'))) {
        $file = $string.Split(' ').Trim() | Where-Object { $_ -match '\w'}
            if($file[0] -eq 'VMAgentPackage.zip') {
                Write-Host "`nFound Vm Agent in $vm"
                Write-Host $($file[0] -as [string]) 'is updated on' $($file[1].Split(" ")[0] -as [string]) -ForegroundColor Green
            } else {
                Write-Host "`n***VM agent doesnt exist in $vm" -ForegroundColor Red
            }
        } 
    }

}