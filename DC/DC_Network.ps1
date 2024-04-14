# Variables
$ServerNetworkInterfaceName = "Server Switch"
$ServerNetworkFirewallIp = "192.168.0.1"
$ServerNetworkDcIp = "192.168.0.2"
$SubnetMask = 24

# Configure DC
New-NetIPAddress -InterfaceAlias $ServerNetworkInterfaceName -IPAddress $ServerNetworkDcIp -AddressFamily IPv4 `
-PrefixLength $SubnetMask -DefaultGateway $ServerNetworkFirewallIp

# Allow ICMP protocol (ping)
New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4 -Enabled True -Direction Inbound -Action Allow