# PSLoadModule

**PSLoadModule** ensures required PowerShell modules are **installed** (from a repository) and **imported** before use.


> Since v1.2.0.0 the primary cmdlet is **`Install-RequiredModule`** (approved verb).  
> `Ensure-Module` remains as an alias for backward compatibility.

Optional badges – 
[![PSGallery Version](https://img.shields.io/powershellgallery/v/PSLoadModule.svg)](https://www.powershellgallery.com/packages/PSLoadModule)
[![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/PSLoadModule.svg)](https://www.powershellgallery.com/packages/PSLoadModule)
[![CI](https://github.com/<YOUR-USER-OR-ORG>/PSLoadModule/actions/workflows/ci.yml/badge.svg)](https://github.com/benlped/PSLoadModule/actions/workflows/ci.yml)


---


## Table of Contents
- [Requirements](#requirements)
- [Installation](#installation)
  - [Install from PowerShell Gallery](#install-from-powershell-gallery)
  - [Import the module](#Import-the-module)
  - [Update the module](#Update-the-module)
- [Quick Start](#quick-start)
- [Usage](#usage)
  - [Install-RequiredModule (primary)](#install-requiredmodule-primary)
  - [Ensure-Module (alias)](#ensure-module-alias)
- [Tips & Troubleshooting](#tips--troubleshooting)
- [Release Notes](#release-notes)

---

## Requirements
- PowerShell **5.1** or **7+**
- Network access to your module repository (defaults to **PSGallery**)

---

## Installation


### Install from PowerShell Gallery

```powershell
# (Optional) trust PSGallery once
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Install for current user (no admin required)
Install-Module -Name PSLoadModule -Scope CurrentUser -Force

# Or for all users (typically requires elevation on Windows)
Install-Module -Name PSLoadModule -Scope AllUsers -Force
```

### Import the module
```PowerShell
Import-Module -Name PSLoadModule
```

### Update the module
```PowerShell
Update-Module -Name PSLoadModule -Force
```


## Quick Start

Ensure **Pester** is installed (from PSGallery) and imported:

```PowerShell
Install-RequiredModule -ModuleName Pester
# or with the alias:
Ensure-Module -ModuleName Pester
```

Handle multiple modules:
```
'Pester','Az.Accounts','Microsoft.Graph' | Install-RequiredModule -Verbose
```

Dry-run (no changes):
```
Install-RequiredModule -ModuleName Az -WhatIf -Verbose
```

Install for all users (usually requires Administrator on Windows):
```
Install-RequiredModule -ModuleName Microsoft.Graph -Scope AllUsers -Confirm
```


Version constraints:
```
# Minimum version
Install-RequiredModule -ModuleName Az -MinimumVersion 11.0.0

# Exact version
Install-RequiredModule -ModuleName Pester -RequiredVersion 5.6.0
```

---

## Usage

### Install-RequiredModule (primary)

Ensures one or more modules are present and imported.

**Behavior:**

1. If a module is already imported → reported as imported.  
2. Else if a suitable version exists locally → imports it.  
3. Else if found in the repository → installs (honors `-Scope`) then imports.  
4. Emits a status object per module: `Name`, `Repository`, `Scope`, `Installed`, `Imported`, `Message`.

**Parameters (summary):**

- `-ModuleName <string[]>` — One or more module names (aliases: `-Name`, `-ModuleNames`).
- `-Repository <string>` — Repository to search/install from. Default: `PSGallery`.
- `-Scope <CurrentUser|AllUsers>` — Install scope. Default: `CurrentUser`.
- `-AllowClobber` — Passed to PowerShellGet v2 (`Install-Module`).
- `-RequiredVersion <version>` — Install/import exactly this version.
- `-MinimumVersion <version>` — Install/import at least this version.
- `-WhatIf` / `-Confirm` — Fully supported (`SupportsShouldProcess`).




```
# Simple ensure
Install-RequiredModule -ModuleName Pester

# Multiple
Install-RequiredModule -ModuleName Pester, Az.Accounts, Microsoft.Graph -Verbose

# Minimum version
Install-RequiredModule -ModuleName Az -MinimumVersion 11.0.0

# Exact version
Install-RequiredModule -ModuleName Pester -RequiredVersion 5.6.0

# AllUsers (typically needs elevation)
Install-RequiredModule -ModuleName Microsoft.Graph -Scope AllUsers -Confirm

# Dry run
Install-RequiredModule -ModuleName Az -WhatIf -Verbose
```

**Implementation notes:**

- Uses **PSResourceGet** (PowerShellGet v3) when available:
  `Find-PSResource` / `Install-PSResource`

- Falls back to PowerShellGet v2:
  `Find-Module` / `Install-Module`


### Ensure-Module (alias)

Ensure-Module is an alias to Install-RequiredModule for backward compatibility.
All examples above work with Ensure-Module.

---

## Tips & Troubleshooting

- **AllUsers requires elevation (Windows)**: run PowerShell as Administrator.
- **Repository not registered?**

```
Register-PSRepository -Default -ErrorAction SilentlyContinue
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
```

- **Older OS / TLS 1.2 (PowerShellGet v2):** if downloads fail, enforce TLS 1.2:
```
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
```
- **Behind a proxy?** Configure system or PowerShellGet/PSResourceGet proxy settings.
- Approved verbs: The exported function is `Install-RequiredModule` (approved).
`Ensure-Module` is an alias, so you won’t see name-check warnings during import.

---


## Release Notes
**v1.2.0.0**
  - New primary cmdlet **Install-RequiredModule** (approved verb); `Ensure-Module` kept as alias
  - Minor fixes and robustness improvements (PSResourceGet/v2 detection, -WhatIf/-Confirm, better logging)

**v1.1.0.0**
- Can now load multi module at once

**v1.0.0.3**
- Extend code to check if module is exists or not

**v1.0.0.2**
- Bug fix
- Include Modules that can not be installed

**v1.0.0.1**
- Bug fix

**v1.0.0.0**
- Full Version