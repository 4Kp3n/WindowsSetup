# Variables
$SubnetMask = 24
# Server network
$ServerNetworkInterfaceName = "Server Switch"
$ServerNetworkFirewallIp = "192.168.0.1"
$ServerNetworkDcIp = "192.168.0.2"
$ServerNetworkDhcpRelayIp = "192.168.0.5"
# Building 1 network
$Building1NetworkInterfaceName = "Building 1 Switch"
$Building1NetworkFirewallIp = "192.168.1.1"
$Building1NetworkDhcpRelayIp = "192.168.1.5"
# Building 2 network
$Building2NetworkInterfaceName = "Building 2 Switch"
$Building2NetworkFirewallIp = "192.168.2.1"
$Building2NetworkDhcpRelayIp = "192.168.2.5"

# Configure Relay server interface
New-NetIPAddress -InterfaceAlias $ServerNetworkInterfaceName -IPAddress $ServerNetworkDhcpRelayIp -AddressFamily IPv4 `
-PrefixLength $SubnetMask -DefaultGateway $ServerNetworkFirewallIp
Set-DnsClientServerAddress -InterfaceAlias $ServerNetworkInterfaceName -ServerAddresses $ServerNetworkDcIp

# Configure Relay building 1 interface
New-NetIPAddress -InterfaceAlias $Building1NetworkInterfaceName -IPAddress $Building1NetworkDhcpRelayIp -AddressFamily IPv4 `
-PrefixLength $SubnetMask -DefaultGateway $Building1NetworkFirewallIp

# Configure Relay building 2 interface
New-NetIPAddress -InterfaceAlias $Building2NetworkInterfaceName -IPAddress $Building2NetworkDhcpRelayIp -AddressFamily IPv4 `
-PrefixLength $SubnetMask -DefaultGateway $Building2NetworkFirewallIp

# Allow ICMP protocol (ping)
New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4 -Enabled True -Direction Inbound -Action Allow