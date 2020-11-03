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

takeown /F C:\Users\trainer\Downloads\* /R /A
icacls C:\Users\trainer\Downloads\*.* /T /grant trainer:F

$File = $file.fullname
$Account = New-Object System.Security.Principal.NTAccount("vm01\trainer")
$FileSecurity = new-object System.Security.AccessControl.FileSecurity
$FileSecurity.SetOwner($Account)
[System.IO.File]::SetAccessControl($File, $FileSecurity)

Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow ;

Return $(Get-WmiObject -Class Win32_Product | Format-List);