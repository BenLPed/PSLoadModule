# PSLoadModule


This module checks if the desired powershell module is installed. If it is imported otherwise it is installed as default from Powershellgallery. But you can specify if you want to install from elsewhere.



## Table of Contents
- [Install module from the PowerShell Gallery](#Install-module-from-the-PowerShell-Gallery)
  - [Import the module](#Import-the-module)
  - [Update the module](#Update-the-module)
- [Usage and Examples](#Usage-and-Examples)
- [Release Notes](#Release-Notes)


# Install module from the PowerShell gallery
Install [PSLoadModule](https://www.powershellgallery.com/packages/PSLoadModule) from PSGallery:

##### Import the module
```PowerShell
Install-Module -Name PSLoadModule -Repository PSGallery -Force
```


##### Update the module
```PowerShell
Update-Module -Name PSLoadModule -Force
```

# Usage and Examples

### Ensure-Module
Ensure-model checks if the module you specified is on the list of modules that cannot be installed from Powershell Gallery. 
Then check it as the module is installed and if it is not installed then it is installed and imported. If it is installed then it is just imported. 

It is an easy way to check the modules you want to import in various scripts.

Installs the Pester modules if they are not already installed from PSGallery:
```PowerShell
Ensure-Module -ModuleName Pester
```

```PowerShell
Ensure-Module -ModuleName Pester -Repository MyRepo -Scope AllUsers
```
``
Checks if the Pester, Az, and Microsoft.Graph modules are installed. 
If they are not installed, the function installs them from the default repository (PSGallery) and imports them.
If they are already installed, then they are simply imported:
```PowerShell
Ensure-Module -ModuleNames Pester, Az, Microsoft.Graph
```

Installs the Pester module from 'MyRepo' and makes it available for all users.
```PowerShell
Ensure-Module -ModuleNames Pester, Az -Repository MyRepo -Scope AllUsers
```

## Release Notes
v1.0.0.0
- Full Version

v1.0.0.2
- Bug fix

v1.0.0.2
- Bug fix
- Include Modules that can not be installed

v1.0.0.3
- Extend code to check if module is exists or not

v1.1.0.0
- Can now load multi module at once