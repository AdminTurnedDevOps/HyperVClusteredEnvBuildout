Param (
[Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName = $true)]
[string[]]$ComputerName,

[Parameter(Mandatory=$true)]
[string]$LogPath

)
$FAPARAMS = @{
              'Name'='Failover-Clustering'
              'LogPath'=$LogPath
              'Restart'=$true
              'IncludeManagementTools'=$true
              'IncludeAllSubFeature'=$true
             }

$InstallFA = install-windowsfeature @FAPARAMS
Invoke-Command -ComputerName $ComputerName -ScriptBlock {$InstallFA}
