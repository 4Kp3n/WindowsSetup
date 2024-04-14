$VMs = @(@("DC", "dc"), @("DHCP Server", "dhcp"), @("DHCP Relay", "relay"), @("Firewall", "firewall"))
$Interface = "Default Switch"
$OutputFile = "C:\Users\andre\.ssh\config"

# Clear the output file if it already exists
if (Test-Path $OutputFile) {
    Remove-Item $OutputFile
}

foreach ($VM in $VMs) {
    $IPaddress = (Get-VMNetworkAdapter -VMName $VM[0] | Where-Object { $_.SwitchName -eq $Interface }).IpAddresses[0]
    if ($IPaddress) {
        $content = @"
Host $($VM[1])
    HostName $IPaddress
    User Administrator
    IdentityFile ~/.ssh/modul1

"@
        Add-Content -Path $OutputFile -Value $content
    } else {
        Add-Content -Path $OutputFile -Value "Host $VM does not have an IP address on $Interface`n"
    }
}

Write-Host "IP address details written to $OutputFile"