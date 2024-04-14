# Variables
$ServerNetworkInterfaceName = "Server Switch"
$ServerNetworkFirewallIp = "192.168.0.1"
$ServerNetworkDhcpIp = "192.168.0.3"
$ServerNetworkDcIp = "192.168.0.2"
$SubnetMask = 24

# Configure DHCP interface
New-NetIPAddress -InterfaceAlias $ServerNetworkInterfaceName -IPAddress $ServerNetworkDhcpIp -AddressFamily IPv4 `
-PrefixLength $SubnetMask -DefaultGateway $ServerNetworkFirewallIp
Set-DnsClientServerAddress -InterfaceAlias $ServerNetworkInterfaceName -ServerAddresses $ServerNetworkDcIp

# Allow ICMP protocol (ping)
New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4 -Enabled True -Direction Inbound -Action Allow