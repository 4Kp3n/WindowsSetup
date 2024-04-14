# High level structure file
$PrivateKeyLocation = "C:\Users\$env:username\.ssh\Server2022"

$DcHostname = "DC01"
$DhcpServerHostname = "DHCP01"
$DhcpRelayHostname = "RELAY01"
$FirewallHostname = "GW01"

# 0. Preparation
# 0.1 Install Software on Host System
Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*" | Add-WindowsCapability -Online
# Enable it on boot
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service sshd
# Check if Firewall is correclty configured
#Get-NetFirewallRule -Name *OpenSSH-Server* |Select-Object Name, DisplayName, Description, Enabled
# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 
# Install and newest PowerShell version (7.4.1 at time of writing)
choco install powershell-core --confirm

# 0.2 Generate SSH keys
# Create .ssh folder in your home
New-Item -ItemType Directory -Path "C:\Users\$env:username\.ssh"
# Generate new SSH keys
ssh-keygen -t ed25519
# SSH public key ergänzen in Skript Common_Setup.ps1

# 1. Create VMs in Hyper-V
# (Execute in terminal with admin rights)
Set-ExecutionPolicy Bypass -Scope Process
Run Create_VMs_with_HyperV.ps1 with Admin rights on host

# 2. Manuelle Installation auf allen VMs (bis zur Anmeldung)

# 3. Run the common setup for all machines (SSH Server und andere Dinge installieren)
# (Admin terminal)
Set-ExecutionPolicy Bypass -Scope Process
Invoke-Command -VMName "Firewall" -FilePath .\Common_Setup.ps1 -ArgumentList "GW01"
Invoke-Command -VMName "Domain Controller" -FilePath .\Common_Setup.ps1 -ArgumentList "DC01"
Invoke-Command -VMName "DHCP Server" -FilePath .\Common_Setup.ps1 -ArgumentList "DHCP01"
Invoke-Command -VMName "DHCP Relay" -FilePath .\Common_Setup.ps1 -ArgumentList "RELAY01"

# Ready to connect!
# Ab hier für alle KOmmandos PowerShell 7 benutzen
# Enter-PSSession -HostName "dc01" -UserName "Administrator" -KeyFilePath C:\Users\andre\.ssh\modul1

# 4. Secific configurations
# 4.1 DC
Invoke-Command -HostName $DcHostname -Username 'Administrator' -Keyfilepath $PrivateKeyLocation -FilePath ".\DC\DC_Network.ps1"

# 4.2 DHCP Server
Invoke-Command -HostName $DhcpServerHostname -Username 'Administrator' -Keyfilepath $PrivateKeyLocation -FilePath ".\DHCP\DHCP_Network.ps1"
Invoke-Command -HostName $DhcpServerHostname -Username 'Administrator' -Keyfilepath $PrivateKeyLocation -FilePath ".\DHCP\DHCP_Configure.ps1"

# 4.3 DHCP Relay
Invoke-Command -HostName $DhcpRelayHostname -Username 'Administrator' -Keyfilepath $PrivateKeyLocation -FilePath ".\Relay\Relay_Network.ps1"

# 4.4 Firewall
Invoke-Command -HostName $FirewallHostname -Username 'Administrator' -Keyfilepath $PrivateKeyLocation -FilePath ".\Firewall\Firewall_Network.ps1"