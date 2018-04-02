Param (
[Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName = $true)]
[string[]]$ComputerName

)
$FAPARAMS = @{
              'Name'='Failover-Clustering'
              'LogPath'=
              'Restart'=$true
              'IncludeManagementTools'=$true
              'IncludeAllSubFeature'=$true
             }

$InstallFA = install-windowsfeature @FAPARAMS
Invoke-Command -ComputerName $ComputerName -ScriptBlock {$InstallFA}
