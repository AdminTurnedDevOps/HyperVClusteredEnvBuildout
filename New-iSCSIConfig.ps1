Function New-iSCSIConfig {
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param (
        [psobject]$ComputerName = 'localhost',
        [string]$LogPath,
        [psobject]$iSCSITargetIPAddress,
        [string]$NodeAddress,
        [string]$ErrorLog

    )
    Begin {}

    Process {
        TRY {
            $InstalliSCSIRolePARAMS = @{
                'ComputerName' = $ComputerName
                'LogPath'      = $LogPath
                'Name'         = 'FS-ISCSITARGET-Server'
                'Verbose'      = $true
            }

            Write-Verbose 'Installing iSCSI Server role'
            $InstalliSCSIController = Install-WindowsFeature @InstalliSCSIRolePARAMS

            $iSCSIControllerObject = [PSCustomObject] @{
                'Hostname' = $ComputerName
                'Success'  = $InstalliSCSIController.Success
                'Restart?' = $InstalliSCSIController.RestartNeeded

            }
            $iSCSIControllerObject

            Write-Verbose 'Confirming iSCSI role was installed successfully'
            IF ($InstalliSCSIController.Success -like 'True') {
                Write-Output 'Installation of iSCSI Windows Feature was successful. We will now continue.'
            }

            ELSE {
                Write-Warning 'Configuration/Installation Error. Please review your parameters and try again. Exiting configuration'
                $Error[0]
                Pause
                Break
            }

            Write-Verbose 'Testing connection to iSCSI target'
            $TestConnection = Test-Connection $iSCSITargetIPAddress
            IF ($TestConnection.PSComputerName -notmatch "\w+") {
                Write-Warning 'The IP address was not reachable. Please try re-running your cmdlet and re-entering a new IP address into your parameter'
                Pause
                Break
            }

            ELSE {
                Write-Verbose 'Setting up switch for ShouldProcess to run'
                [switch]$Continue = $true
            }
            IF ($PSCmdlet.ShouldProcess($Continue)) {
                FOREACH ($Computer in $ComputerName) {

                    Write-Verbose 'Starting iSCSI service'
                    Start-Service -Name MSiSCSI
                    Write-Verbose 'Confirming iSCSI start is started automatically'
                    Set-Service -Name MSiSCSI -StartupType Automatic

                    Write-Verbose 'Creating new iSCSI target portal'
                    $NewiSCSITargetPortal = New-IscsiTargetPortal -TargetPortalAddress $iSCSITargetIPAddress

                    Write-Verbose 'Connecting iSCSI target'
                    $ConnectiISCSITargetPortal = Connect-IscsiTarget -NodeAddress $NodeAddress
                    $ConnectiISCSITargetPortal 

                    $iSCSIConfig = [pscustomobject] @{
                        'TargetPortalAddress' = $NewiSCSITargetPortal.TargetPortalAddress
                        'TargetPortalNumber'  = $NewiSCSITargetPortal.TargetPortalPortNumber
                        'NodeAddress'         = $NodeAddress
                    }
                    $iSCSIConfig | ft
        
                }#FOREACH
            }#ShouldProcessIF
        }#TRY
        CATCH {
            Write-Warning 'An error has occured. Please check the error logs in your specific file share'
            $_ | Out-File $ErrorLog
            Throw
        }#CATCH
    }#Process
    End {}
}#Function
