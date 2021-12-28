
#open powershell elevated as administrator and run set execution policy unrestricted mode before
$testchoco = powershell choco -v
if(-not($testchoco)){
    Write-Output "Seems Chocolatey is not installed, installing now"
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
else{
    Write-Output "Chocolatey Version $testchoco is already installed"
}

# or

if(test-path "C:\ProgramData\chocolatey\choco.exe"){
Write-Host "choco installed"

}

# Make `refreshenv` available right away, by defining the $env:ChocolateyInstall
# variable and importing the Chocolatey profile module.
# Note: Using `. $PROFILE` instead *may* work, but isn't guaranteed to.
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."   
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

# refreshenv is now an alias for Update-SessionEnvironment
# (rather than invoking refreshenv.cmd, the *batch file* for use with cmd.exe)
# This should make git.exe accessible via the refreshed $env:PATH, so that it
# can be called by name only.
refreshenv

# Verify that git can be called.


$testvb = powershell vboxmanage -v
if(-not($testvb)){
    Write-Output "Seems oracle virtual box is not installed, installing now"
    choco install virtualbox  -y
}
else{
    Write-Output "oracle virtual box Version $testovb is already installed"
}

# or

if(test-path "C:\ProgramData\virtualbox\virtualbox.exe"){
Write-Host "oracle vb installed"
}



$Networkpath = "T:\RnD\SW\Linux\VMs" 
$pathExists = Test-Path -Path $Networkpath
$currentDir = (Get-Item .).FullName
$workspace = New-Item -ItemType "directory" -Path "C:\Users\$env:username\Documents\vm"

if ($pathExists)  {
Write-host "Path already existed"
Import-Module BitsTransfer
Start-BitsTransfer -Source $Networkpath\\AirMachine_Base.zip -Destination $workspace -Description "copy airspan build machine image" -DisplayName "copy airspan build machine image"
#Copy-Item -Path $Networkpath\\AirMachine_Base.zip -Destination $cwd
Expand-Archive -Path $workspace\AirMachine_Base.zip -DestinationPath $workspace
Return      #end the function if path was already there
}
else {
Write-host "demo create mapped drive"
#(new-object -com WScript.Network).MapNetworkDrive("X:","\\Server-01\Share")
}    

#Path wasn't there, so we created it, now testing that it worked

$pathExists = Test-Path -Path $Networkpath

If (-not ($pathExists)) {
Write-Host "We tried to create the path but it still isn't there"
#Insert email code here 
}

else {Write-Host "Path created successfully"}

