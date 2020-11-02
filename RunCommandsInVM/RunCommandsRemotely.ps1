$rg = "frontend-servers-rg"
$vms =  (Get-AzVM -ResourceGroupName $rg).Name

foreach($vm in $vms) {
    $count = 0;
    Write-Host "`nChecking in $vm"
    $response = Invoke-AzVMRunCommand -ResourceGroupName $rg -VMName $vm -CommandId 'RunPowerShellScript' -ScriptPath 'C:\Users\vrk4c\Documents\PowerShell\Scripts\RunCommandsInVM\WinAgent.ps1'
    $output = $response.value[0].message
    foreach ($string in $($output.Split("`n"))) {
        if($string -match '\w' -and !($string.startswith('Name'))) {
            $file = $string.Split(' ').Trim() | Where-Object { $_ -match '\w'}
            if($file[0] -eq 'VMAgentPackage.zip') {
                $count++;
                Write-Host $($file[0] -as [string]) 'is updated on' $($file[1].Split(" ")[0] -as [string])
            } 
        } 
    }
    if($count -eq 1) { Write-Host "Found Vm Agent in $vm" -ForegroundColor Green; } 
    else { Write-Host "***VM agent doesnt exist in $vm" -ForegroundColor Red; }
}