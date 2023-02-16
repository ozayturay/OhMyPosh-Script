Function Check-RunAsAdministrator()
{
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  if(!$CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
    $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
    $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
    $ElevatedProcess.Verb = "runas"
    [System.Diagnostics.Process]::Start($ElevatedProcess)
    Exit
  }
}

$CHOCO = $env:PROGRAMDATA + "\chocolatey\bin\choco.exe"
$OHMYPOSH = $env:LOCALAPPDATA + "\Programs\oh-my-posh\bin\oh-my-posh.exe"
$HACKFONT = $PSScriptRoot + "\hack-nerdfont.zip"
$PROFILEBAK = $PROFILE + ".bak"

$UNCHOCO = $env:PROGRAMDATA + "\chocolatey"
$UNOHMYPOSH = $env:LOCALAPPDATA + "\Programs\oh-my-posh\unins000.exe /verysilent"
 
Check-RunAsAdministrator

Write-Host "Setting up required permissions..."
Set-ExecutionPolicy RemoteSigned
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Write-Host ""

if (Test-Path -Path $PROFILE -PathType Leaf)
{
  Write-Host "Profile found, deleting and restoring backup..."
  Write-Host "Deleting profile..."
  Remove-Item $PROFILE
  Write-Host "Profile $PROFILE has been deleted!"
  
  if (Test-Path -Path $PROFILEBAK -PathType Leaf)
  {
    Write-Host "Old backup found, restoring..."  
    Get-Item -Path $PROFILEBAK | Move-Item -Destination $PROFILE
    Write-Host "Profile backup $PROFILEBAK has been restored!"
  }
}

Write-Host ""

if (Test-Path -Path $OHMYPOSH -PathType Leaf)
{
  Write-Host "Oh-My-Posh is installed, uninstalling..."
  Cmd /C $UNOHMYPOSH
}

Write-Host ""

if (Test-Path -Path $CHOCO -PathType Leaf)
{
  Write-Host "Chocolatey is installed, uninstalling..."
  Remove-Item $UNCHOCO -Recurse 
}

Write-Host ""

if (Test-Path -Path $HACKFONT -PathType Leaf)
{
  Write-Host "Hack Nerd Font is present, deleting..."
  Remove-Item $HACKFONT
}

Write-Host ""

if (Get-Module -ListAvailable -Name Terminal-Icons)
{
  Write-Host "Terminal-Icons module is installed, uninstalling..."
  UnInstall-Module -Name Terminal-Icons
}

Write-Host ""
Write-Host "UnInstallation finished."
Write-Host "Press any key to continue..."
Cmd /C "Pause >NUL"
Write-Host ""