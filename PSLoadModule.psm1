

# Function to check if a module is installed
function Check-Module {
    param (
        [string]$ModuleName
    )
    $module = Get-Module -ListAvailable -Name $ModuleName
    if ($module) {
        return $true
    } else {
        return $false
    }
}


# Function to ensure a module is installed and loaded
function Ensure-Module {
    <#
    .SYNOPSIS
    Ensures that a specific module is installed from a given repository.

    .DESCRIPTION
    Ensure-Module checks if the module is installed. If it is not installed, the function installs it from the default repository (PSGallery) and imports the module. 
    If the module is already installed, it simply imports the module.

    .PARAMETER ModuleName
    The name of the module to be installed.

    .PARAMETER Repository
    (Optional) The name of the repository from which the module should be installed. The default is 'PSGallery'.

    .PARAMETER Scope
    (Optional) Specifies whether the module should be installed for the CurrentUser or AllUsers. The default is 'CurrentUser'.

    .EXAMPLE
    Ensure-Module -ModuleName Pester

    Installs the Pester module if it is not already installed from PSGallery.

    .EXAMPLE
    Ensure-Module -ModuleName Pester

    Checks if the Pester module is installed. If it is not installed, the function installs it from the default repository (PSGallery) and imports the module. 
    If Pester is already installed, it simply imports the module.

    .EXAMPLE
    Ensure-Module -ModuleName Pester -Repository MyRepo -Scope AllUsers

    Installs the Pester module from 'MyRepo' and makes it available for all users.

    .NOTES
    Author: Benni Ladevig Pedersen
    Version: 1.0.0.0
    #>

    param(
        [string]$ModuleName,
        [string]$Repository = "PSGallery",
        [string]$Scope = "CurrentUser"
    )

    # Funktionens logik her


    if (-not (Check-Module -ModuleName $ModuleName)) {
        Write-Host "Module $ModuleName not found. Installing..." -BackgroundColor Red -NoNewline
        Install-Module -Name $ModuleName -Scope $Scope -Repository $Repository -Force
        Write-Host " " -NoNewline
        Write-Host "Done" -BackgroundColor Green
    } else {
        Write-Host "Module $ModuleName is already installed." -BackgroundColor Green -NoNewline
        Write-Host "" -ForegroundColor White -BackgroundColor Black
    }
    
    Write-Host "Module $ModuleName loades." -BackgroundColor Green -NoNewline
    Write-Host "." -BackgroundColor Green -NoNewline
    Import-Module -Name $ModuleName -Force
    Write-Host "." -BackgroundColor Green -NoNewline
    Write-Host "Done" -BackgroundColor Green -NoNewline
    Write-Host "" -ForegroundColor White -BackgroundColor Black
}


# $ModuleName = "Microsoft.Graph"