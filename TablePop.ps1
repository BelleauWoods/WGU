#Isaiah Woods Martin        StudentID: 001393994

Import-Module SQLServer

$instance = 'SRV19-Primary\SQLExpress'
$dbName = 'ClientDB'
$createDatabase = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database -ArgumentList $instance, $dbName
$dbresult = Get-SQLDatabase -ServerInstance $instance | Where-Object{$_.Name -eq $dbName}

try {
    if ($null -eq $dbresult) {
        Write-Host "[$dbName] NOT FOUND" 
        Write-Output "Creating Database: $dbName ..." 
        $createDatabase
        $createDatabase.Create()
            if ($null -eq $dbresult){
                Write-Output "Failure creating $dbName" 
            }
            else {
                Write-Output "Completed" 
                $dbresult
            }
    }
    else {
        Write-Host "$[dbName] found. Deleting before progress" 
        Invoke-SQLcmd -ServerInstance $instance -database master -Query "DROP DATABASE [$dbName]"
            if ($null -eq $dbresult) {
                Write-Host "[$dbName] successfully deleted."  
            }
            else {
                Write-Host "Database deletion unsuccessful." 
            }
        Write-Output "Creating Database: $dbName" 
        $createDatabase
        $createDatabase.Create()
            if ($null -eq $dbresult){
                Write-Output "Failure creating $dbName" 
            }
            else {
                Write-Output "Completed" 
                $dbresult
            }
    }
}

catch {
    Write-Output "Services unsuccessful. Confirm that PowerShell SQLServer module has been imported prior to running this execution." 
}

$tableName = "Client_A_Contacts"
$ClientData = Import-Csv 'C:\Users\LabAdmin\Desktop\Requirements2\NewClientData.csv'
$tableScript = "
CREATE TABLE $tableName (
    first_name varchar(255),
    last_name varchar(255),
    city varchar(255),
    county varchar(255),
    zip int,
    officePhone int,
    mobilePhone int,
);"

$tableresult = Invoke-SQLcmd -ServerInstance $instance -Query $tablescript -Database $dbname 
$table = $dbresult.Tables[$tableName] #Creates a variable tied to an exact database with the specified tablename

Write-SQLTableData -TableName $tableName -ServerInstance $instance -DatabaseName $dbName -InputData $ClientData

$tableresult
$table
Invoke-Sqlcmd -Database ClientDB –ServerInstance .\SQLEXPRESS -Query ‘SELECT * FROM dbo.Client_A_Contacts’ > C:\Users\LabAdmin\Desktop\Requirements2\SqlResults.txt
