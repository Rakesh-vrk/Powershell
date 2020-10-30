$response = Invoke-AzVMRunCommand -ResourceGroupName 'win-vm01' -VMName 'win-vm01' -CommandId 'RunPowerShellScript' -ScriptPath 'C:\Users\vrk4c\Documents\PowerShell\Scripts\RunCommandsInVM\diskspace.ps1'

$output = $response.value[0].message

foreach ($string in $($output.Split("`n"))) {
    if($string -match '\w' -and !($string.startswith('Name'))) {
    $disk = $string.Split(' ').Trim() | Where-Object { $_ -match '\w'}
    $($disk[0] -as [string]) + ' drive is having ' + $($disk[2].Split(" ")[0] -as [string]) + ' GB of free space.'
    } 
}

