#variable for allocating random resource group name
$resourceGroupName = "rg-$(Get-Random)";

#variable for Resource group location
$location = "westus2"

#variable for setting an admin login and password for SQL server
$adminSqlLogin = "SqlAdmin"
$password = "Administrator1"

#variable for server name - the logical server name has to be unique in the system
$serverName = "server-$(Get-Random)"

#variable for database name
$databaseName = "Sampledb001"

#variable for The ip address range that you want to allow to access SQL server
$startIp = "0.0.0.0"
$endIp = "255.255.255.255"

#variable for getting info of created Resoruce group
$resourceGroup=@();

#variable for getting info on created SQL server
$server=@();

#variable for getting info on updated server FirewallRules
$serverFirewallRule=@();

#variable for getting info on created 
$database=@();

$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminSqlLogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force)

# Create a resource group
$resourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $location

Write-Host "`nCreating SQL server with name:"$serverName -ForegroundColor Yellow

# Create a server with a system wide unique server name
$server = New-AzSqlServer -ResourceGroupName $resourceGroupName -ServerName $serverName `
            -Location $location -SqlAdministratorCredentials $cred

Write-Host "`nCreated SQL Server here is the info about it:`n"$server -ForegroundColor Green

# Create a server firewall rule that allows access from the specified IP range
$serverFirewallRule = New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName `
                                                  -ServerName $serverName -FirewallRuleName "AllowedIPs" `
                                                  -StartIpAddress $startIp -EndIpAddress $endIp

Write-Host "`nHere are the details about Firewall rules"$serverFirewallRule -ForegroundColor Green

Write-Host "`nCreating database with name" $databaseName "in" $serverName "SQL server" -ForegroundColor Yellow

# Create a blank database with an S0 performance level
$database = New-AzSqlDatabase  -ResourceGroupName $resourceGroupName -ServerName $serverName `
                                -DatabaseName $databaseName -RequestedServiceObjectiveName "S0" `
                                -SampleName "AdventureWorksLT"

Write-Host "`nCreated" $databaseName "Database" $serverName "in SQL Server here is the info about it:`n"$database -ForegroundColor Green

Write-Host "`nHere is the metric value of the database :" -ForegroundColor Yellow

# Monitor the DTU consumption on the imported database in 5 minute intervals
$MonitorParameters = @{
  ResourceId = "/subscriptions/$($(Get-AzContext).Subscription.Id)/resourceGroups/$resourceGroupName/providers/Microsoft.Sql/servers/$serverName/databases/$databaseName"
  TimeGrain = [TimeSpan]::Parse("00:05:00")
  MetricNames = "dtu_consumption_percent"
}
(Get-AzMetric @MonitorParameters -DetailedOutput).Data

# Set an alert rule to automatically monitor DTU in the future
Add-AzMetricAlertRule -ResourceGroup $resourceGroupName -Name "MySampleAlertRule" -Location $location `
                      -TargetResourceId "/subscriptions/$($(Get-AzContext).Subscription.Id)/resourceGroups/$resourceGroupName/providers/Microsoft.Sql/servers/$serverName/databases/$databaseName" `
                      -MetricName "dtu_consumption_percent" -Operator "GreaterThan" -Threshold 90 `
                      -WindowSize $([TimeSpan]::Parse("00:05:00")) -TimeAggregationOperator "Average" `
                      -Action $(New-AzAlertRuleEmail -SendToServiceOwner)


# Scale the database performance to Standard S1
$database = Set-AzSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $servername `
                              -DatabaseName $databasename -Edition "Standard" `
                              -RequestedServiceObjectiveName "S1"

Write-Host "`nDeleting the resource group with name :" $resourceGroupName -ForegroundColor Yellow

If ((Get-AzResourceGroup | Select-Object -Property ResourceGroupName) -match $resourceGroupName) {
    Remove-AzResourceGroup -Name $resourceGroupName -Force
    Write-Host "Success"
} else {
    Write-Host "Failed"
}

Write-Host "`nDeleted the entire resources in" $resourceGroupName "Resource Group" -ForegroundColor Green
