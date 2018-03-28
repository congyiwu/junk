# Gives you file cleanup wizard and other stuff
Install-WindowsFeature Desktop-Experience

# Install a few services we'll set up below:
Install-WindowsFeature File-Services, SMTP-Server, Windows-Server-Backup

# Install Chocolatey from https://chocolatey.org

###################################################################################################
# Enable tcpip, network pipes, and browser on sqlexpress
###################################################################################################
$wmi = [wmi]'root\Microsoft\SqlServer\ComputerManagement10:ServerNetworkProtocol.InstanceName="SQLEXPRESS",ProtocolName="Tcp"'
$wmi.SetEnable()
# if $wmi.Enabled -eq $true then it's already enabled

$wmi = [wmi]'root\Microsoft\SqlServer\ComputerManagement10:ServerNetworkProtocol.InstanceName="SQLEXPRESS",ProtocolName="Np"'
$wmi.SetEnable()
# if $wmi.Enabled -eq $true then it's already enabled

# you have to restart SQL Server if the settings above are changed
$wmi = [wmi]'root\Microsoft\SqlServer\ComputerManagement10:SqlService.ServiceName="MSSQL$SQLEXPRESS",SQLServiceType=1'
$wmi.StopService()
$wmi.StartService()
# if $wmi.State -eq 4 then the service is started

$wmi = [wmi]'root\Microsoft\SqlServer\ComputerManagement10:SqlService.ServiceName="SQLBrowser",SQLServiceType=7'
$wmi.SetStartMode(2)
if ($wmi.State -ne 4) {
    $wmi.StartService()
}
# if $wmi.StartMode -eq 2 -and $wmi.State -eq 4 then the service is set to start automatically and is currently started


# Disable IE ESC
# See http://blogs.msdn.com/b/askie/archive/2009/06/23/how-to-disable-ie-enhanced-security-on-windows-2003-server-silently.aspx
#Add reg keys, just in case, to prepare for next step
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' -Name 'IsInstalled' -Value 0
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}' -Name 'IsInstalled' -Value 0
#Removing IE Enhanced Security from System  
Rundll32.exe iesetup.dll,IEHardenUser
Rundll32.exe iesetup.dll,IEHardenAdmin
Rundll32.exe iesetup.dll,IEHardenMachineNow
#Disabling IEHarden for user
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap' -Name 'IEHarden' -Value 0
#Removes form Add Remove Components
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OC Manager\Subcomponents' -Name 'iehardenadmin' -Value 0
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OC Manager\Subcomponents' -Name 'iehardenuser' -Value 0
#Removed the Values from the IEHarden installed components key
Remove-Item 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' -Recurse
Remove-Item 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}' -Recurse


# Show hidden files
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty $key 'Hidden' 1 -Type DWord

# Show protected system files
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty $key 'ShowSuperHidden' 1 -Type DWord

# Show extensions for known file types
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty $key 'HideFileExt' 0 -Type DWord

# Don't display Shutdown Event Tracker
$key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability'
$null = New-Item $key -ItemType Folder
Set-ItemProperty $key 'ShutdownReasonOn' 0 -Type DWord

# Shutdown: Allow system to be shut down without having to log on
$key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-ItemProperty $key 'shutdownwithoutlogon' 1 -Type DWord

# Set defaults for command prompt
$key = 'HKCU:\Console'
Set-ItemProperty $key 'FaceName' 'Consolas'
# Font size 12
Set-ItemProperty $key 'FontFamily' 0x00000036 -Type DWord
# Not Bold
Set-ItemProperty $key 'FontWeight' 0x00000190 -Type DWord
# Height=300,Width=120
Set-ItemProperty $key 'ScreenBufferSize' 0x3e80078 -Type DWord
#Height=300,Width=120
Set-ItemProperty $key 'WindowSize' 0x00190078 -Type DWord

# Disable automatic machine account password changes that happen every 30 days.
# Normally if you restore the an old VM snapshot past this boundary, you'll have to remove it from
# the domain and readd it before you can log in
# https://support.microsoft.com/en-us/kb/154501/
$key = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'
Set-ItemProperty $key 'DisablePasswordChange' 1 -Type DWord

# Enable PowerShell scripts
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Unrestricted


# Enable Remote Desktop
# System Properties -> Performance -> Adjust for best performance of: Programs
# Interactive logon: Do not require CTRL+ALT+DEL
# For VM Hosts - disable antivirus for VMs, enlistments.
# Install Desktop Experience
# Enable backups
# Enable file dedupe

#cleanup windows updates (disables rollback)
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase


# sysprep a Hyper-V VM
# /mode:vm tells sysprep to NOT remove hardware info, so it doesn't have to redetect hardware upon reboot, which is faster.
sysprep /generalize /shutdown /oobe /mode:vm

# Install powershell modules
Install-Module PSReadLine
Install-Module posh-git
. "C:\Program Files\WindowsPowerShell\Modules\posh-git\0.5.0.2015\install.ps1"

# Add task in Task Scheduler to run AutoHotkey as admin when I log

git config --global alias.lg 'log --graph'
git config --global alias.showns 'show --name-status'
