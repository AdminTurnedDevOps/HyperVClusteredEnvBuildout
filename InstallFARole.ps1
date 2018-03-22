Param (
[Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName = $true)]
[string[]]$ComputerName

)
$FAPARAMS = @{
              'Name'='Failover-Clustering'
              'LogPath'='\\NEWCCI-VMFS1\vol1\shared\center\X CCI_ADMIN\TECH SUPPORT\Admin\_ServerConfigLogs\FailoverClusterInstallLog.txt'
              'Restart'=$true
              'IncludeManagementTools'=$true
              'IncludeAllSubFeature'=$true
             }

$InstallFA = install-windowsfeature @FAPARAMS
Invoke-Command -ComputerName $ComputerName -ScriptBlock {$InstallFA}
