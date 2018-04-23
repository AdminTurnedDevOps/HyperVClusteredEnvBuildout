Function New-HyperVM {
    [cmdletbinding(DefaultParameterSetName = 'NewVM', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    Param (
        [Parameter(ParameterSetName = 'NewVM',
            Position = 0,
            Mandatory=$true)]
        [string]$Name,

        [Parameter(ParameterSetName = 'NewVM',
            Position = 1)]
        [string]$VMSwitch,

        [Parameter(ParameterSetName = 'NewVM',
            Position = 2)]
        [ValidateSet('2GB', '4GB')]
        [string]$MemoryStartup = 2GB,

        [Parameter(ParameterSetName = 'NewVM')]
        [string]$NewVHDSize = 50GB,

        [Parameter(ParameterSetName = 'NewVM')]
        [string]$NewVHDPath,

        [Parameter(ParameterSetName = 'NewVM',
            Mandatory=$true,
            HelpMessage='Please type in a path to store your VM')]
        [string]$Path
    )
    Begin {
        $hosts = @()
        $hosts += $Name
        Write-Output "Starting: $MyInvocation.MyCommand"

        Write-Verbose 'Creating directory for new VM'
        Foreach ($VMName in $Name) {
            New-Item -Path $Path -Name "$VMName" -ItemType Directory
        }
    }

    Process {
        Try {
            IF ($PSBoundParameters.ContainsKey('NewVHDPath')) {
                $NewVHD = New-VHD -Path $NewVHDPath -SizeBytes $NewVHDSize
                $NewVHDOBJECT = [pscustomobject] @{
                    'Hostname'  = $NewVHD.ComputerName
                    'VHDFormat' = $NewVHD.VhdFormat
                    'VHDXSize'  = $NewVHD.Size / 1GB
                }
                Write-Verbose 'Outputting results of new VHD'
                $NewVHDOBJECT
            }#IF

            IF (-Not($NewVHDPath)) {
                Write-Warning 'The VHDX path was not found. Please try again...'
                Pause
                
            }

            ELSE {

                $NewVMParams = @{
                    'Name'               = $Name
                    'Path'               = "D:\hyperv\$Name"
                    'MemoryStartupBytes' = $MemoryStartup
                    'VHDPath'            = $NewVHDPath
                    'SwitchName'         = $VMSwitch
                    'Generation'         = '2'
                }
                $NewVM = New-VM @NewVMParams

                $NewVMOBJECT = [pscustomobject] @{
                    'VMName'         = $NewVM.Name
                    'VMCurrentState' = $NewVM.State
                    'VMStatus'       = $NewVM.Status
                    'VMGeneration'   = $NewVM.Generation                           
                }
                $NewVMOBJECT

            }#Else
        }#Try

        Catch {
                $HyperVServer
                $TestHyperVServerConnection = Test-Connection $HyperVServer
                $IPregex=‘(?<Address>((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))’
                IF ($TestHyperVServerConnection.IPv4Address.IPAddressToString[0] -match $IPregex ) {
                    Write-Output 'Connection to Hyper-V Server: Successful. Moving on...'
                }

                Else {
                    Write-Warning 'Connection to Hyper-V Server: UNSUCCESSFUL'
                    Pause
                    Break
                }

                $TestVHDXPath = Test-Path $NewVHDPath
                IF($TestVHDXPath -like 'true')
                {
                    Write-Output 'Path to VHDX: Successful. Moving on...'
                }

                Else {
                    Write-Warning 'Connection to VHDX: UNSUCCESSFUL'
                    Pause
                    Break
                }

                Write-Warning 'Please review the errors below'
                $PSCmdlet.ThrowTerminatingError($_)                
        }#Catch
    }#Process
    End {}
}#Function
