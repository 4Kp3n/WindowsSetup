# Path and content of the autorized_keys file
# ssh-keygen -t ed25519
$PubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFlepUq2KqbT1lD/2HMwWTak3Dbu8xWNf5C6EkBE9rU CloudCommander"
$SshKeyFile = "C:\ProgramData\ssh\administrators_authorized_keys"
$SshConfigFile = "C:\ProgramData\ssh\sshd_config"
#The following needs to be added to the SSH config file in C:\ProgramData\ssh\sshd_config
$SubstituteLine = 'Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -nologo'

# FOLLOWING SOFTWARE MUST ALSO BE AVAILABLE ON THE HOST!!!
# Install SSH Server
Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*" | Add-WindowsCapability -Online
# Enable it on boot
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service sshd
# Check if Firewall is correclty configured
#Get-NetFirewallRule -Name *OpenSSH-Server* |Select-Object Name, DisplayName, Description, Enabled
# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 
# Install Vim and newest PowerShell version (7.4.1 at time of writing)
choco install vim --confirm
# Path to PowerShell executable after installation: "C:\Program Files\PowerShell\7\pwsh.exe"
choco install powershell-core --confirm


# Configure SSH keys
Add-Content -Path $SshKeyFile -Value $PubKey
# Set correct permissions for authorized_keys file
icacls.exe ""$env:ProgramData\ssh\administrators_authorized_keys"" /inheritance:r /grant ""Administratoren:F"" /grant ""SYSTEM:F""

# Virtual NICs added without the switch "DeviceNaming" set to On have no value set in DisplayValue, and will be ignored
foreach ($N in (Get-NetAdapterAdvancedProperty -DisplayName "Hyper-V Network Adapter Name" | Where-Object DisplayValue -NotLike "")) {
  $N | Rename-NetAdapter -NewName $n.DisplayValue -Verbose
} 

# Change the line in SSH config file
(Get-Content $SshConfigFile) -replace '^Subsystem.*$', $SubstituteLine |Set-Content $SshConfigFile

if ($args[0]) {
  Rename-Computer -NewName $args[0]
}

Restart-Computer -Force