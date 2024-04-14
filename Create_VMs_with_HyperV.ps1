#TODO Define a variable $Name equal to the current VM that gets configured (e.g. $Name = $DcName) to make the code easier reusable

# Variables for virtual switches
$DefaultSwitch = "Default Switch"
$ServerSwitch = "Server Switch"
$Building1Switch = "Building 1 Switch"
$Building2Switch = "Building 2 Switch"
$ServerVlan = 100
#$Building1Vlan = 200 # not used, done with for loop and math
#$Building2Vlan = 300 # not used, done with for loop and math
# Installation medium
$PathToWindowsServerIso = "C:\Users\$env:username\HyperV\SERVER_EVAL_x64FRE_de-de.iso"
# DC variables
$DcName = "Domain Controller"
$DcVhdxPath = "C:\Users\$env:username\HyperV\DC.vhdx"
# DHCP server variables
$DhcpName = "DHCP Server"
$DhcpVhdxPath = "C:\Users\$env:username\HyperV\DHCP_Server.vhdx"
# DHCP relay agent variables
$DhcpRelayName = "DHCP Relay"
$DhcpRelayVhdxPath = "C:\Users\$env:username\HyperV\DHCP_Relay.vhdx"
# Firewall variables
$FirewallName = "Firewall"
$GatewayVhdxPath = "C:\Users\$env:username\HyperV\Gateway.vhdx"

# Create the switches in HyperV
New-VMSwitch -Name $ServerSwitch -SwitchType Internal 
New-VMSwitch -Name $Building1Switch -SwitchType Internal 
New-VMSwitch -Name $Building2Switch -SwitchType Internal 

#################################################################################################################################################
# Setup DC
#################################################################################################################################################
$Name = $DcName
New-VM -Name $Name -MemoryStartupBytes 2GB -NewVHDPath $DcVhdxPath -NewVHDSizeBytes 40GB -Generation 2 -SwitchName $DefaultSwitch
Add-VMNetworkAdapter -VMName $Name -SwitchName $ServerSwitch
# Select the second VMNetworkAdapter, the $ServerSwitch and configure the $ServerVlan
Get-VMNetworkAdapter -vmname $Name |Select-Object -index 1 | Set-VMNetworkAdapterVlan -Access -VlanId $ServerVlan
# Add descriptive name to the network interfaces (instead of 'Netzwerkkarte') to be later able to rename the interfaces in the VM
Get-VMNetworkAdapter -VMName $Name |Set-VMNetworkAdapter -DeviceNaming On #Prerequisite
# Get a list of all the switches the $VM has NICs connected to
$VmSwitches = (Get-VMNetworkAdapter -VMName $Name).SwitchName
# Rename each NIC of the VM to the name of the virtual switch it is connected to
foreach ($Switch in $VmSwitches) { 
  Get-VMNetworkAdapter -VMName $Name | Where-Object SwitchName -eq $Switch | Rename-VMNetworkAdapter -NewName $Switch -Verbose 
} 
# Add installation medium
Add-VMDvdDrive -VMName $Name -Path $PathToWindowsServerIso
# Set boot order (ISO first, than the drive)
Set-VMFirmware -VMName $Name -BootOrder $(Get-VMDvdDrive -VMName $Name), $(Get-VMHardDiskDrive -VMName $Name)

#################################################################################################################################################
# Setup DHCP server
#################################################################################################################################################
New-VM -Name $DhcpName -MemoryStartupBytes 2GB -NewVHDPath $DhcpVhdxPath -NewVHDSizeBytes 40GB -Generation 2 -SwitchName $DefaultSwitch
Add-VMNetworkAdapter -VMName $DhcpName -SwitchName $ServerSwitch
Get-VMNetworkAdapter -vmname $DhcpName |Select-Object -index 1 | Set-VMNetworkAdapterVlan -Access -VlanId $ServerVlan
Get-VMNetworkAdapter -VMName $DhcpName |Set-VMNetworkAdapter -DeviceNaming On #Prerequisite
$VmSwitches = (Get-VMNetworkAdapter -VMName $DhcpName).SwitchName
foreach ($Switch in $VmSwitches) { 
  Get-VMNetworkAdapter -VMName $DhcpName | Where-Object SwitchName -eq $Switch | Rename-VMNetworkAdapter -NewName $Switch -Verbose 
} 
Add-VMDvdDrive -VMName $DhcpName -Path $PathToWindowsServerIso
Set-VMFirmware -VMName $DhcpName -BootOrder $(Get-VMDvdDrive -VMName $DhcpName), $(Get-VMHardDiskDrive -VMName $DhcpName)

#################################################################################################################################################
# Setup DHCP relay agent
#################################################################################################################################################
New-VM -Name $DhcpRelayName -MemoryStartupBytes 2GB -NewVHDPath $DhcpRelayVhdxPath -NewVHDSizeBytes 40GB -Generation 2 -SwitchName $DefaultSwitch
Add-VMNetworkAdapter -VMName $DhcpRelayName -SwitchName $ServerSwitch
Add-VMNetworkAdapter -VMName $DhcpRelayName -SwitchName $Building1Switch
Add-VMNetworkAdapter -VMName $DhcpRelayName -SwitchName $Building2Switch
# For loop to set the VLAN IDs
for ($i=1; $i -le 3; $i++) {
    Get-VMNetworkAdapter -vmname $DhcpRelayName |Select-Object -index $i | Set-VMNetworkAdapterVlan -Access -VlanId $(($i)*100)
}
Get-VMNetworkAdapter -VMName $DhcpRelayName |Set-VMNetworkAdapter -DeviceNaming On #Prerequisite
$VmSwitches = (Get-VMNetworkAdapter -VMName $DhcpRelayName).SwitchName
foreach ($Switch in $VmSwitches) { 
  Get-VMNetworkAdapter -VMName $DhcpRelayName | Where-Object SwitchName -eq $Switch | Rename-VMNetworkAdapter -NewName $Switch -Verbose 
} 
Add-VMDvdDrive -VMName $DhcpRelayName -Path $PathToWindowsServerIso
Set-VMFirmware -VMName $DhcpRelayName -BootOrder $(Get-VMDvdDrive -VMName $DhcpRelayName), $(Get-VMHardDiskDrive -VMName $DhcpRelayName)

#################################################################################################################################################
# Setup Gateway
#################################################################################################################################################
New-VM -Name $FirewallName -MemoryStartupBytes 2GB -NewVHDPath $GatewayVhdxPath -NewVHDSizeBytes 40GB -Generation 2 -SwitchName $DefaultSwitch
Add-VMNetworkAdapter -VMName $FirewallName -SwitchName $ServerSwitch
Add-VMNetworkAdapter -VMName $FirewallName -SwitchName $Building1Switch
Add-VMNetworkAdapter -VMName $FirewallName -SwitchName $Building2Switch
# For loop to set the VLAN IDs
for ($i=1; $i -le 3; $i++) {
    Get-VMNetworkAdapter -vmname $FirewallName |Select-Object -index $i | Set-VMNetworkAdapterVlan -Access -VlanId $(($i)*100)
}
Get-VMNetworkAdapter -VMName $FirewallName |Set-VMNetworkAdapter -DeviceNaming On #Prerequisite
$VmSwitches = (Get-VMNetworkAdapter -VMName $FirewallName).SwitchName
foreach ($Switch in $VmSwitches) { 
  Get-VMNetworkAdapter -VMName $FirewallName | Where-Object SwitchName -eq $Switch | Rename-VMNetworkAdapter -NewName $Switch -Verbose 
} 
Add-VMDvdDrive -VMName $FirewallName -Path $PathToWindowsServerIso
Set-VMFirmware -VMName $FirewallName -BootOrder $(Get-VMDvdDrive -VMName $FirewallName), $(Get-VMHardDiskDrive -VMName $FirewallName)