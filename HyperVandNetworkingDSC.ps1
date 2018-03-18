Install-Module xPSDesiredStateConfiguration -force
Install-Module xNetworking -Force


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
        [int]$SubnetMask,

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
            Credential = $Credential
        }

        xIPAddress NewIP
        {
            IPAddress = "192.168.1.0"
            InterfaceAlias = "Ethernet"
            SubnetMask = "24"
            AddressFamily  = "IPV4"
        }
    }#Node
}#Config

Restart-Computer $Nodename