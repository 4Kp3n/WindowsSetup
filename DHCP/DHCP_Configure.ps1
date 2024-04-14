# Add DHCP server to domain
$DomainName = "awesome.local"
$NetbiosName = "AWESOME"
$User = "$DomainName\Administrator"
$Password = ConvertTo-SecureString "Sup3rS4f3PW!!!" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential('Administrator', $Password)

Add-Computer -DomainName $DomainName -Credential $Credential


## Installieren der DHCP-Serverrolle
#Install-WindowsFeature -Name DHCP -IncludeManagementTools
#
## Warten auf die Installation
#Start-Sleep -Seconds 10
#
## DHCP-Serverdienst autorisieren im Active Directory, falls notwendig
#Add-DhcpServerInDC -DnsName "zion.local" -IPAddress "192.168.0.100"
#Set-DnsClientServerAddress -InterfaceAlias "sw01" -ServerAddresses 192.168.0.100
#
## DHCP-Post-Installationskonfiguration
#Set-DhcpServerv4DnsSetting -DynamicUpdates "Always" -DeleteDnsRrOnLeaseExpiry $true
#
## Einen neuen DHCP-Bereich erstellen
#
#$dhcpScopeName = "MORPHEUS-NETZ"
#$startRange = "192.168.0.101"
#$endRange = "192.168.0.200"
#$subnetMask = "255.255.255.0" 
#$defaultGateway = "192.168.0.5"
#$dnsServer = "192.168.0.100"
#
## DHCP-Bereich hinzufügen
#Add-DhcpServerv4Scope -Name $dhcpScopeName -StartRange $startRange -EndRange $endRange -SubnetMask $subnetMask -State Active
#Set-DhcpServerv4OptionValue -DnsDomain "zion.local" -DnsServer $dnsServer -Router $defaultGateway
#
## DHCP-Bereich aktivieren
#Set-DhcpServerv4Scope -ScopeId $startRange -State Active