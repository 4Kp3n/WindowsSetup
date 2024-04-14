#################################################################################

# OU erstellen
$dn = "DC=zion,DC=local"
$man = "OU=Management,DC=zion,DC=local"
New-ADOrganizationalUnit -Name "Management" -Path $dn -Description "Der Chef"
New-ADOrganizationalUnit -Name "Entwicklung" -Path $man -Description "Die Entwicklung"
New-ADOrganizationalUnit -Name "Mitarbeiter" -Path $man -Description "Die Mitarbeiter"
New-ADOrganizationalUnit -Name "Testing" -Path $man -Description "Das TestTeam!"

# Benutzerinformationen
$users = @(
    @{Username="User1"; Password="Password1"; OU="OU=Management,DC=zion,DC=local"},
    @{Username="User2"; Password="Password2"; OU="OU=Entwicklung,OU=Management,DC=zion,DC=local"},
    @{Username="User3"; Password="Password3"; OU="OU=Mitarbeiter,OU=Management,DC=zion,DC=local"},
    @{Username="User4"; Password="Password4"; OU="OU=Testing,OU=Management,DC=zion,DC=local"}
)
 


foreach ($user in $users) {
    $securePassword = ConvertTo-SecureString -AsPlainText $user.Password -Force
    $userParameters = @{
        SamAccountName        = $user.Username
        UserPrincipalName     = "$($user.Username)@zion.local"
        Name                  = $user.Username
        GivenName             = $user.Username
        Surname               = "Surname"
        Enabled               = $true
        DisplayName           = "$($user.Username) Surname"
        Path                  = $user.OU
        AccountPassword       = $securePassword
    }
    New-ADUser @userParameters
}

###############################################

# "Klaus" als neuen Benutzer anlegen und zur Administratoren-Gruppe hinzufügen

$Password = ConvertTo-SecureString "InitialesPasswort123!" -AsPlainText -Force
New-LocalUser -Name "Klaus" -Password $Password -FullName "Klaus Admin" -Description "Client Admin"

# Benutzer zur lokalen Administratorengruppe hinzufügen
Add-ADGroupMember -Identity "Administratoren" -Members "Klaus"

###############################################

# Erstellen der Ordner
$folders = @("Entwicklung", "Management", "Mitarbeiter", "Testing")
foreach ($folder in $folders) {
    New-Item -Path "C:\$folder" -ItemType Directory
}
 
# Einrichten der Freigaben mit spezifischen Berechtigungen
New-SmbShare -Name "Entwicklung" -Path "C:\Entwicklung" -ChangeAccess "User2"
New-SmbShare -Name "Management" -Path "C:\Management" -ChangeAccess "User1"
New-SmbShare -Name "Mitarbeiter" -Path "C:\Mitarbeiter" -ChangeAccess "User3"
New-SmbShare -Name "Testing" -Path "C:\Testing" -ChangeAccess "User4"
 
# Zusätzliche NTFS-Berechtigungen setzen, falls notwendig
$aclEntwicklung = Get-Acl "C:\Entwicklung"
$aclManagement = Get-Acl "C:\Management"
$aclMitarbeiter = Get-Acl "C:\Mitarbeiter"
$aclTesting = Get-Acl "C:\Testing"
 
# Anpassen der NTFS-Berechtigungen für jeden Ordner
# Beispiel für Entwicklung und Management, wiederholen Sie dies entsprechend für Mitarbeiter und Testing
$ruleEntwicklung = New-Object System.Security.AccessControl.FileSystemAccessRule("User2", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$aclEntwicklung.SetAccessRule($ruleEntwicklung)
Set-Acl "C:\Entwicklung" $aclEntwicklung
 
$ruleManagement = New-Object System.Security.AccessControl.FileSystemAccessRule("User1", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$aclManagement.SetAccessRule($ruleManagement)
Set-Acl "C:\Management" $aclManagement
 
# Wiederholen Sie die Anpassung der NTFS-Berechtigungen für Mitarbeiter und Testing mit User3 und User4


###############################################

# Passwortrichtlinie 12 Zeichen

# Importieren des Active Directory Moduls
Import-Module ActiveDirectory

# Setzen der Passwortrichtlinie für die Domäne
# Set-ADDefaultDomainPasswordPolicy -MinPasswordLength 12 -ComplexityEnabled $true
Set-ADDefaultDomainPasswordPolicy -Identity "zion.local" -MinPasswordLength 12 -ComplexityEnabled $true

###############################################

###############################################

# GPO alle zulassen

$GPol = New-GPO -Name Powershell-REG-KEYS -Comment "auf Admin Maschinen" -Domain zion.local 

# Benutzereinstellungen deaktivieren
$GPol.GpoStatus = 'UserSettingsDisabled'


# GPO Einstellungen 1
$PO1= @{
Name = 'Powershell-REG-KEYS'
Key = 'HKLM\Software\Policies\Microsoft\Windows\PowerShell'
ValueName = 'EnableScripts'
Type = 'DWord'
Value = 1
}
# GPO Einstellungen setzen
Set-GPRegistryValue @PO1 | Out-Null

# GPO Einstellungen 2
$PO2= @{
Name = 'Powershell-REG-KEYS'
Key = 'HKLM\Software\Policies\Microsoft\Windows\PowerShell'
ValueName = 'ExecutionPolicy'
Value = 'Unrestricted'
Type = 'String'
}
# GPO Einstellungen setzen
Set-GPRegistryValue @PO2 | Out-Null

# Letzer Anwender bei der Anmeldung darf nicht angezeigt werden

# Registry-Pfad setzen, wo die Einstellung gespeichert ist
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

# Schlüsselwert setzen, um den letzten angemeldeten Benutzer zu verbergen
Set-ItemProperty -Path $registryPath -Name "DontDisplayLastUserName" -Value 1

###############################################

# Bilderschirmschoner auf 15 Minuten

# Bildschirmschoner aktivieren
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'ScreenSaveActive' -Value '1'

# Bildschirmschoner-Timeout auf 900 Sekunden (15 Minuten) setzen
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'ScreenSaveTimeOut' -Value '900'

# (Optional) Pfad zum Bildschirmschoner festlegen, z.B. Mystify
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'SCRNSAVE.EXE' -Value 'C:\Windows\System32\Mystify.scr'


# Registry-Pfad setzen, wo die Einstellung gespeichert ist
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

# Schlüsselwert setzen, um zu erzwingen, dass STRG+ALT+ENTF gedrückt werden muss
Set-ItemProperty -Path $registryPath -Name "DisableCAD" -Value 0

###############################################

# NICHT-Administratoren haben keinen Zugriff auf die Registry

# Pfad zum Registry-Schlüssel für die Deaktivierung von Regedit
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System"

# Deaktivieren von Regedit - Setzt den Wert "DisableRegistryTools" auf 1
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
Set-ItemProperty -Path $regPath -Name "DisableRegistryTools" -Value 1

###############################################

# USB-Stick deaktivieren

# Pfad zum Registry-Schlüssel
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR"

# Setzen des Registry-Werts, um USB-Speichergeräte zu deaktivieren
Set-ItemProperty -Path $regPath -Name "Start" -Value 4

###############################################

# A_Record DNS eintragen
# Importieren des DNS-Server-Moduls (falls erforderlich)
Install-WindowsFeature -Name DNS -IncludeManagementTools
Add-DnsServerResourceRecordA -Name "matrix" -ZoneName "zion.local" -IPv4Address "192.168.0.100"

# Administrator umbenennen und deaktivieren - wichtig!
## Rename-LocalUser -Name "Administrator" -NewName "Ladmin"; Disable-LocalUser -Name "Ladmin"


Import-Module ActiveDirectory
# Ermitteln des Distinguished Name (DN) des Benutzers
$UserDN = (Get-ADUser -Identity Administrator).DistinguishedName

# Umbenennen des Benutzers
Rename-ADObject -Identity $UserDN -NewName "Ladmin"

# Aktualisieren von SamAccountName und UserPrincipalName
Set-ADUser -Identity Ladmin -SamAccountName Ladmin -UserPrincipalName Ladmin@zion.local