#Reference https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/agent-windows

Set-location 'C:\Users\trainer\Downloads'
Invoke-WebRequest https://go.microsoft.com/fwlink/?LinkID=394789 -OutFile VmAgent.msi

$file = Get-ChildItem | Where-Object {$_.Name -eq 'VmAgent.msi'}

$DataStamp = get-date -Format yyyyMMddTHHmmss
$logFile = '{0}-{1}.log' -f $file.fullname,$DataStamp
$MSIArguments = @(
    "/i"
    ('"{0}"' -f $file.fullname)
    "/qn"
    "/norestart"
    "/L*v"
    $logFile
)

Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow ;

Return $(Get-WmiObject -Class Win32_Product | Format-List);