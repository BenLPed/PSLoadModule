# PSLoadModule.psm1 — eager loader + alias
$publicPath = Join-Path -Path $PSScriptRoot -ChildPath 'Public'
$implPath   = Join-Path -Path $publicPath   -ChildPath 'Install-RequiredModule.ps1'

if (-not (Test-Path -LiteralPath $implPath)) {
    throw "PSLoadModule: Missing file '$implPath'."
}

. "$implPath"  # definerer function Install-RequiredModule

# Alias: Ensure-Module -> Install-RequiredModule
Set-Alias -Name 'Ensure-Module' -Value 'Install-RequiredModule' -Scope Script

# Ingen Export-ModuleMember her; manifestet eksporterer
