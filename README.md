# PSLoadModule


This module checks if the desired powershell module is installed. If it is imported otherwise it is installed as default from Powershellgallery. But you can specify if you want to install from elsewhere.



## Table of Contents
- [PSScriptLogging](#ScriptLogging)
- [Install module from the PowerShell Gallery](#Install-module-from-the-PowerShell-Gallery)
  - [Import the module](Import-the-module)
  - [Update the module](Update-the-module)
- [Usage and Examples](#Usage-and-Examples)
  - [Start-Log](#Start-Log)
  - [Write-Log](#Write-Log)
- [Software to view the .log fil](#Software-to-view-the-.log-fil)
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
You started logging by using Start-Log. Here you tall what the script should be called, where it should be located, which company, description of what the script does, number of days the log files should be saved

It checks if the folder is created, otherwise it is created. It then checks whether the file exists, otherwise it is created.
It then stores the default information, so that there is no doubt when a new run has started, especially if it runs several times on the same day.

```PowerShell
Ensure-Module -ModuleName PSLoadModule
```

```PowerShell
Ensure-Module -ModuleName Pester -Repository MyRepo -Scope AllUsers
```

![alt text](Images/Start-Log.png?raw=true)

### Write-Log
When you want to add something to the log, you write **write-log "what needs to happen or what happens"** and it is added to the log file. By default, it automatically sets LogLevet to 1, but if you want to draw attention to something, you can change LogLevel to 2 and the log text will turn yellow. If LogLevel is set to 3, the text turns red, it cut bee used in case of error.


v1.0.0.0
- Full Version

v1.0.0.2
- Bug fix

v1.0.0.2
- Bug fix
- Include Modules that can not be installed