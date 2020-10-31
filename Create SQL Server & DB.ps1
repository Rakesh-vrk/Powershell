#variable for keeping subscription count
$subcount=1;

#variable for having account details
$AccDet= @();

#variable which will have the subscription name
$sub = "String";

#variable for checking valid subscription provided
$subcheck=1;

#variable for Subscription details
$subdetails=@();

#variable for allocating random resource group name
$resourceGroupName = "rg-$(Get-Random)";

#variable for Resource group location
$location = "westus2"

#variable for setting an admin login and password for SQL server
$adminSqlLogin = "SqlAdmin"
$password = "ChangeYourAdminPassword1"

#variable for server name - the logical server name has to be unique in the system
$serverName = "server-$(Get-Random)"

#variable for database name
$databaseName = "SampleDatabase"

#variable for The ip address range that you want to allow to access SQL server
$startIp = "0.0.0.0"
$endIp = "0.0.0.0"

#variable for getting info of created Resoruce group
$resourceGroup=@();

#variable for getting info on created SQL server
$server=@();

#variable for getting info on updated server FirewallRules
$serverFirewallRule=@();

#variable for getting info on created 
$database=@();

#connect Az account 
Write-Host "******** Login to your Azure Account *********"

#Taking account details
$AccDet=Connect-AzAccount

Get-AzSubscription | ForEach-Object {

    Write-Host $subcount " -- " $_.Name;
        
    #variable which will have the subscription name
    $sub=$_.Name;

    $subcount++;

}
    
if($subcount -eq 2) {
    Write-Host "`nThere is only one subscription, which is `""$sub "`" and we are selecting it";
} else {

    DO {

        $sub=Read-Host "Provide the Subscription Name "

        Get-AzSubscription | ForEach-Object {

            if($sub -contains $_.Name) {
                $subcheck=2;
            } 

        }

        if ($subcheck -eq 1) {
            Write-Host "`nEnter valid subscription name" -ForegroundColor Red
        }

    } while($subcheck -eq 1)

}

Write-Host "`n"

#variable for Subscription details
$subdetails=Select-AzSubscription -SubscriptionName $sub
$subdetails=Get-AzSubscription

Write-Host "`nYou are in subscription :"$sub -ForegroundColor Green

Write-Host "`nCreating resource group with name:"$resourceGroupName -ForegroundColor Yellow

# Create a resource group
$resourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $location

Write-Host "`nCreated Resource group here is the info about it:`n"$resourceGroup -ForegroundColor Green

Write-Host "`nCreating SQL server with name:"$serverName -ForegroundColor Yellow

# Create a server with a system wide unique server name
$server = New-AzSqlServer -ResourceGroupName $resourceGroupName -ServerName $serverName -Location $location -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminSqlLogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))

Write-Host "`nCreated SQL Server here is the info about it:`n"$server -ForegroundColor Green

Write-Host "`nUpdating Firewall rules for" $serverName "SQL server." -ForegroundColor Yellow

# Create a server firewall rule that allows access from the specified IP range
$serverFirewallRule = New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $serverName -FirewallRuleName "AllowedIPs" -StartIpAddress $startIp -EndIpAddress $endIp

Write-Host "`nUpdated Firewall rules for" $serverName "SQL Server here is the info about it:`n"$serverFirewallRule -ForegroundColor Green

Write-Host "`nCreating database with name" $databaseName "in" $serverName "SQL server" -ForegroundColor Yellow

# Create a blank database with an S0 performance level
$database = New-AzSqlDatabase  -ResourceGroupName $resourceGroupName -ServerName $serverName -DatabaseName $databaseName -RequestedServiceObjectiveName "S0" -SampleName "AdventureWorksLT"

Write-Host "`nCreated" $databaseName "Database" $serverName "in SQL Server here is the info about it:`n"$database -ForegroundColor Green

Write-Host "`nHere is the metric value of the database :" -ForegroundColor Yellow

# Monitor the DTU consumption on the imported database in 5 minute intervals
$MonitorParameters = @{
  ResourceId = "/subscriptions/$($(Get-AzContext).Subscription.Id)/resourceGroups/$resourceGroupName/providers/Microsoft.Sql/servers/$serverName/databases/$databaseName"
  TimeGrain = [TimeSpan]::Parse("00:05:00")
  MetricNames = "dtu_consumption_percent"
}
(Get-AzMetric @MonitorParameters -DetailedOutput).MetricValues

# Scale the database performance to Standard S1
$database = Set-AzSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $servername -DatabaseName $databasename -Edition "Standard" -RequestedServiceObjectiveName "S1"

# Set an alert rule to automatically monitor DTU in the future
Add-AzMetricAlertRule -ResourceGroup $resourceGroupName -Name "MySampleAlertRule" -Location $location -TargetResourceId "/subscriptions/$($(Get-AzContext).Subscription.Id)/resourceGroups/$resourceGroupName/providers/Microsoft.Sql/servers/$serverName/databases/$databaseName" -MetricName "dtu_consumption_percent" -Operator "GreaterThan" -Threshold 90 -WindowSize $([TimeSpan]::Parse("00:05:00")) -TimeAggregationOperator "Average" -Action $(New-AzAlertRuleEmail -SendToServiceOwner)

Write-Host "`nDeleting the resource group with name :" $resourceGroupName -ForegroundColor Yellow

If ((Get-AzResourceGroup | Select-Object -Property ResourceGroupName) -match $resourceGroupName) {
    Remove-AzResourceGroup -Name $resourceGroupName -Force
    Write-Host "Success"
} else {
    Write-Host "Failed"
}

Write-Host "`nDeleted the entire resources in" $resourceGroupName "Resource Group" -ForegroundColor Green
