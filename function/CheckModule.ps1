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

