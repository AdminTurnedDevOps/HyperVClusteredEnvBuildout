# ** Below are the needed modules. Please install these prior to running the DSC config.
#Install-Module xPSDesiredStateConfiguration -force
#Install-Module xNetworking -Force

$ConfigPath = (Read-Host 'Please enter a DSC config path')
mkdir -Path $ConfigPath
Configuration HyperVandNetworkingConfig
{
    Param(
        [ValidateNotNullOrEmpty()]
        [string]$Nodename = 'localhost',

        [ValidateNotNullOrEmpty()]
        [string]$IPAddress,
        
        [ValidateNotNullOrEmpty()]
        [string]$InterfaceAlias,

        [ValidateNotNullOrEmpty()]
        [string]$SubnetMask,

        [ValidateNotNullOrEmpty()]
        [string]$AddressFamily

    )
    Import-Module PSDesiredStateConfiguration
    Import-module xNetworking
    Import-DscResource -Module xNetworking
    Node $Nodename
    {

        WindowsFeature InstallHyperV
        {
            Ensure = 'present'
            Name = 'Hyper-V'
            IncludeAllSubFeature = $true
        }

        xIPAddress NewIP
        {
            IPAddress = $IPAddress
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = $AddressFamily
        }
    }#Node
}#Config

HyperVandNetworkingConfig -OutputPath $ConfigPath
Start-DscConfiguration -Wait -Force -Path $ConfigPath -verbose
