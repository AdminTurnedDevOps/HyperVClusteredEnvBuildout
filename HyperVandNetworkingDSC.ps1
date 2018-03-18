Install-Module xPSDesiredStateConfiguration -force
Install-Module xNetworking -Force

$ConfigPath = (Read-Host 'Please enter a config path')
mkdir -Path $ConfigPath
Configuration HyperVandNetworkingConfig
{
    Param(
        [ValidateNotNullOrEmpty()]
        [string]$Nodename = 'localhost',

        [ValidateNotNullOrEmpty()]
        [string]$IPAddress = '192.168.1.16',

        [ValidateNotNullOrEmpty()]
        [string]$InterfaceAlias = 'Ethernet0',

        [ValidateNotNullOrEmpty()]
        [int]$SubnetMask = '24',

        [ValidateNotNullOrEmpty()]
        [string]$AddressFamily = 'IPv4'




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
