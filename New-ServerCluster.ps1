#1, Cluster service cannot be started due to machines not currently being in a cluster. If the machines are in a cluster, then they can check the cluster available disks
Function New-ServerCluster {
    [cmdletbinding(DefaultParameterSetName='ClusterConfig',SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param (
        [Parameter(ParameterSetName='ClusterConfig',
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Please enter your nodes that you are connecting to your new cluster')]
        [ValidateNotNull()]
        [Alias('ComputerName', 'NodeName')]
        [psobject[]]$Node,

        [Parameter(ParameterSetName='ClusterConfig',
            Position = 1,
            Mandatory = $true,
            HelpMessage = 'Please enter a name for your cluster')]
        [ValidateNotNull()]
        [Alias('Cluster', 'Name', 'HAClusterName')]
        [string]$ClusterName
    
    )
    Begin {
        Write-Output 'We will now begin cluster testing to ensure network, storage, connection to AD, and roles are set up properly.' 
        Write-Output 'Please Note: A cluster does not have to be set up prior. Only the role needs to be installed'
        Write-Output 'Please ensure you put all servers that you want to cluster and test in as comma-separated'
        
        $TestConnection = Test-Connection $Node
        IF (-Not($TestConnection)) {
            Write-Warning 'No connection was established to the specified nodes. Please try again...'
            Pause
            Exit
        }

        ELSE {
            Write-Output 'Connection to servers established. We will now proceed...'
            Pause
        }
    }    
    Process { 
        Try {
            IF ($PSBoundParameters.ContainsKey('Node')) {   
                ## ** Run a test on the cluster after it's set up as well **
                $TestCluster = Test-Cluster -Node $Node -Verbose
                $TestClusterOBJECTS = [pscustomobject] @{
                    'LastWriteDateandTime' = $TestCluster.LastWriteTime
                    'NameOfReport'         = $TestCluster.Name
                }
                $TestClusterOBJECTS
    
                $Input = Read-Host 'The test has completed. If passed, please press 1. If not, please press 2 to exit and fix issues'
                switch ($Input) {
    
                    '1' {
                        Write-Verbose 'Creating new cluster'
                        $NewClusterPARAMS = @{
                            'Name'    = $ClusterName
                            'Node'    = $Node
                            'Verbose' = $true
                        }
                        New-Cluster @NewClusterPARAMS           
                    }#1
            
                    '2' {
                        Pause
                        Exit
                    }#2
                }#Switch
            }
############################################################################### Storage Portion Below ####################################################################

            $NewClusterDiskQuestion = Read-Host 'Would you like to get your available disk clusters and add them to your cluster now? Y for yes or N to exit'
            IF ($NewClusterDiskQuestion -like 'y') {
                #Get available cluster disks
                Write-Output 'Please ensure you have your shared disk configured on BOTH clustered hosts.'

                Write-Verbose 'Setting Cluster Service to startup type: Automation'
                Set-Service -Name ClusSvc -StartupType Automatic

                Write-Verbose 'Starting Cluster Service'
                Start-Service -Name ClusSvc

                $GetDisk = Get-ClusterAvailableDisk

                FOREACH ($ClustDisk in $GetDisk) {
                    $ClusterDiskObject = [pscustomobject] @{
                        'Cluster' = $ClustDisk.Cluster
                        'Name'    = $ClustDisk.Name
                        'Size'    = $ClustDisk.Size
                    }
                    $ClusterDiskObject | Format-Table

                }#FOREACH
        
                #Connect clustered storage
                Pause
                Get-ClusterAvailableDisk | Add-ClusterDisk        
            }
    
            ELSE {
                Pause
                Exit
            } #ELSE
        }#TRY
        CATCH {
            $ClusteredDisks = Get-ClusterAvailableDisk
            $ClusteredDisksObject = [pscustomobject] @{
                                                       'Name' = $ClusteredDisks.Name
                                                      }
            $ClusteredDisksObject

            Write-Warning 'An error has occursed. Please review the logs in your specified ErrorLog location'
            $_ | Out-File $ErrorLog
            #Throw error to host
            $_
            Throw                                            
        }
    }#Process
    End {Write-Verbose 'The function has completed'}
}#Function
