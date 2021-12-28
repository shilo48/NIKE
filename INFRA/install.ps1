#open powershell elevated as administrator and run set execution policy unrestricted mode before

function install_choco {
    $testchoco = powershell choco -v
    if(-not($testchoco)){
        Write-Output "#### Seems Chocolatey is not installed, installing now ####"
        Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    else{
        Write-Output "#### Chocolatey Version $testchoco is already installed ####"
    }

    # or

    if(test-path "C:\ProgramData\chocolatey\choco.exe"){
    Write-Host "#### choco installed ####"

    }
    
}

function refresh_env {
    # Make `refreshenv` available right away, by defining the $env:ChocolateyInstall
    # variable and importing the Chocolatey profile module.
    # Note: Using `. $PROFILE` instead *may* work, but isn't guaranteed to.
    $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."   
    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

    # refreshenv is now an alias for Update-SessionEnvironment
    # (rather than invoking refreshenv.cmd, the *batch file* for use with cmd.exe)
    # This should make git.exe accessible via the refreshed $env:PATH, so that it
    # can be called by name only.
    Write-Output "#### refreshenv ####"
    refreshenv
}


function install_packages {
    Write-Output "#### $package installing now ####"
    choco install $package  -y
}

$package=$args[0]

Write-Host "#### start install packages ####"

install_choco
refresh_env
install_packages 

Write-Host "####  packages finish to installed ####"



