# Function to ensure modules are installed and imported
function Ensure-Module {
<#
.SYNOPSIS
Ensures one or more modules are installed (from a repository) and imported.

.DESCRIPTION
For each module name:
- If the module is already imported, it is skipped (reported as Imported = $true).
- If not imported but available locally, it is imported.
- If not available locally and present in the repository, it is installed (respecting Scope)
  and then imported.
- All actions respect -WhatIf/-Confirm.

Supports both PSResourceGet (PowerShellGet v3) and PowerShellGet v2.

.PARAMETER ModuleName
One or more module names to ensure.

.PARAMETER Repository
Repository to search/install from. Defaults to 'PSGallery'.

.PARAMETER Scope
Install scope. 'CurrentUser' (default) or 'AllUsers' (typically requires elevation on Windows).

.PARAMETER AllowClobber
Allow clobber when installing via PowerShellGet v2 (Install-Module).

.PARAMETER RequiredVersion
Install/import exactly this version.

.PARAMETER MinimumVersion
Install/import at least this version (cannot be combined with -RequiredVersion).

.EXAMPLE
Ensure-Module -ModuleName Pester

Ensures Pester is installed from PSGallery (CurrentUser) and imported.

.EXAMPLE
'Pester','Az.Accounts' | Ensure-Module -Verbose

Pipeline usage. Writes a status object per module.

.EXAMPLE
Ensure-Module -ModuleName Microsoft.Graph -Scope AllUsers -Confirm

Prompt before installing/importing for all users.

.EXAMPLE
Ensure-Module -ModuleName Az -MinimumVersion 11.0.0 -Verbose

Ensure Az (>= 11.0.0) is installed/imported.

.EXAMPLE
Ensure-Module -ModuleName Pester -RequiredVersion 5.6.0 -WhatIf

Show what would happen, but do not perform changes.

.NOTES
Author: Benni Ladevig Pedersen
Version: 1.2.0.0
#>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [string[]]$ModuleName,

        [string]$Repository = 'PSGallery',

        [ValidateSet('CurrentUser','AllUsers')]
        [string]$Scope = 'CurrentUser',

        [switch]$AllowClobber,

        [Version]$RequiredVersion,

        [Version]$MinimumVersion
    )

    begin {
        # Validate version parameter combination
        if ($PSBoundParameters.ContainsKey('RequiredVersion') -and $PSBoundParameters.ContainsKey('MinimumVersion')) {
            throw "You cannot specify both -RequiredVersion and -MinimumVersion."
        }

        # Warn if AllUsers likely requires elevation (Windows)
        if ($Scope -eq 'AllUsers') {
            try {
                $isAdmin = $false
                if ($IsWindows) {
                    $wp = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
                    $isAdmin = $wp.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
                }
                if (-not $isAdmin) {
                    Write-Warning "Installing to -Scope AllUsers typically requires an elevated session (Run as Administrator)."
                }
            } catch { }
        }

        # Prefer PSResourceGet if available
        $usePSResourceGet = Get-Command Install-PSResource -ErrorAction SilentlyContinue

        # Validate repository registration based on the stack in use
        if ($usePSResourceGet) {
            if (-not (Get-Command Get-PSResourceRepository -ErrorAction SilentlyContinue)) {
                # Older PSResourceGet previews might not have Get-PSResourceRepository; skip hard validation in that case
                Write-Verbose "PSResourceGet detected but Get-PSResourceRepository not available; skipping repo validation."
            }
            else {
                $repoPSR = Get-PSResourceRepository -Name $Repository -ErrorAction SilentlyContinue
                if (-not $repoPSR) {
                    Write-Warning "PSResourceGet in use, but repository '$Repository' is not registered (Get-PSResourceRepository)."
                }
            }
        }
        else {
            if (-not (Get-PSRepository -Name $Repository -ErrorAction SilentlyContinue)) {
                throw "Repository '$Repository' is not registered (Get-PSRepository)."
            }
        }
    }

    process {
        foreach ($mn in $ModuleName) {

            # Output object we’ll fill along the way
            $result = [pscustomobject]@{
                Name       = $mn
                Repository = $Repository
                Scope      = $Scope
                Installed  = $false
                Imported   = $false
                Message    = $null
            }

            # 0) Already imported?
            if (Get-Module -Name $mn) {
                Write-Verbose "Module '$mn' is already imported."
                $result.Imported = $true
                $result
                continue
            }

            # Build finder params
            $inRepo = $null
            try {
                if ($usePSResourceGet) {
                    $findParams = @{ Name = $mn; Repository = $Repository; ErrorAction = 'SilentlyContinue' }
                    if ($PSBoundParameters.ContainsKey('RequiredVersion')) {
                        # PSResourceGet expects exact version via -Version, not -RequiredVersion
                        $findParams['Version'] = $RequiredVersion.ToString()
                    } elseif ($PSBoundParameters.ContainsKey('MinimumVersion')) {
                        # PSResourceGet allows range format: ">= x.y.z"
                        $findParams['Version'] = ">= $($MinimumVersion.ToString())"
                    }
                    $inRepo = Find-PSResource @findParams
                }
                else {
                    $findParams = @{ Name = $mn; Repository = $Repository; ErrorAction = 'SilentlyContinue' }
                    if ($PSBoundParameters.ContainsKey('RequiredVersion')) {
                        $findParams['RequiredVersion'] = $RequiredVersion
                    } elseif ($PSBoundParameters.ContainsKey('MinimumVersion')) {
                        $findParams['MinimumVersion'] = $MinimumVersion
                    }
                    $inRepo = Find-Module @findParams
                }
            } catch {
                Write-Verbose "Find in repo failed for '$mn': $($_.Exception.Message)"
            }

            # 1) Available locally (specific/min version aware)?
            $availableLocal = $null
            try {
                if ($PSBoundParameters.ContainsKey('RequiredVersion')) {
                    $availableLocal = Get-Module -ListAvailable -Name $mn | Where-Object { $_.Version -eq $RequiredVersion }
                } elseif ($PSBoundParameters.ContainsKey('MinimumVersion')) {
                    $availableLocal = Get-Module -ListAvailable -Name $mn | Where-Object { $_.Version -ge $MinimumVersion }
                } else {
                    $availableLocal = Get-Module -ListAvailable -Name $mn
                }
            } catch {
                Write-Verbose "Local availability check failed for '$mn': $($_.Exception.Message)"
            }

            # 2) Install if not local but available in repo
            if (-not $availableLocal -and $inRepo) {
                $doInstall = $true
                if ($null -ne $PSCmdlet) {
                    $doInstall = $PSCmdlet.ShouldProcess($mn, "Install from $Repository ($Scope)")
                }
                if ($doInstall) {
                    try {
                        if ($usePSResourceGet) {
                            $installParams = @{ Name = $mn; Repository = $Repository; Scope = $Scope; Force = $true; ErrorAction = 'Stop' }
                            if ($PSBoundParameters.ContainsKey('RequiredVersion')) {
                                $installParams['Version'] = $RequiredVersion.ToString()
                            } elseif ($PSBoundParameters.ContainsKey('MinimumVersion')) {
                                $installParams['Version'] = ">= $($MinimumVersion.ToString())"
                            }
                            Install-PSResource @installParams
                        }
                        else {
                            $installParams = @{ Name = $mn; Repository = $Repository; Scope = $Scope; Force = $true; ErrorAction = 'Stop'; AllowClobber = $AllowClobber }
                            if ($PSBoundParameters.ContainsKey('RequiredVersion')) {
                                $installParams['RequiredVersion'] = $RequiredVersion
                            } elseif ($PSBoundParameters.ContainsKey('MinimumVersion')) {
                                $installParams['MinimumVersion'] = $MinimumVersion
                            }
                            Install-Module @installParams
                        }
                        $result.Installed = $true
                        Write-Verbose "Installed '$mn' from $Repository ($Scope)."
                    } catch {
                        $result.Message = $_.Exception.Message
                        Write-Error "Failed installing '$mn': $($result.Message)"
                    }
                }
            }

            # 3) Import if available now (local or just installed)
            #    Import also respects ShouldProcess for full WhatIf coverage
            $nowAvailable = $result.Installed -or $availableLocal
            if ($nowAvailable) {
                $doImport = $true
                if ($null -ne $PSCmdlet) {
                    $doImport = $PSCmdlet.ShouldProcess($mn, "Import module")
                }
                if ($doImport) {
                    try {
                        if ($PSBoundParameters.ContainsKey('RequiredVersion')) {
                            Import-Module -FullyQualifiedName @{ ModuleName = $mn; RequiredVersion = $RequiredVersion } -ErrorAction Stop
                        } elseif ($PSBoundParameters.ContainsKey('MinimumVersion')) {
                            Import-Module -Name $mn -MinimumVersion $MinimumVersion -ErrorAction Stop
                        } else {
                            Import-Module -Name $mn -ErrorAction Stop
                        }
                        $result.Imported = $true
                        Write-Verbose "Imported '$mn'."
                    } catch {
                        $result.Message = $_.Exception.Message
                        Write-Error "Failed importing '$mn': $($result.Message)"
                    }
                }
            }
            else {
                Write-Warning "Module '$mn' not found locally and not available in repository '$Repository'."
            }

            # 4) Emit result for this module
            $result
        }
    }
}
