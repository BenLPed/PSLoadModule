# ScriptLogging

This module can help you create logging in your scripts. You write **write-log "what needs to happen or what happens"**. You can follow along live, which makes it easy to see what is happening. It also records which user runs the script, which line of the script is executed and the time. So if something goes wrong, it's easy to find out what went wrong.

![Complet view of Logfil](Images//fullPic.png?raw=true)

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
Install [PSScriptLogging](https://www.powershellgallery.com/packages/PSScriptLogging) from PSGallery:

##### Import the module
```PowerShell
Install-Module -Name PSScriptLogging -Repository PSGallery -Force
```

##### Update the module
```PowerShell
Update-Module -Name PSScriptLogging -Force
```

# Usage and Examples

### Start-Log
You started logging by using Start-Log. Here you tall what the script should be called, where it should be located, which company, description of what the script does, number of days the log files should be saved

It checks if the folder is created, otherwise it is created. It then checks whether the file exists, otherwise it is created.
It then stores the default information, so that there is no doubt when a new run has started, especially if it runs several times on the same day.

```PowerShell
Start-Log -FilePath "\\LogShare$\ADUsers" -FileName "ListOfAdUsers" -Company "BLIT" -Description "Find all users in our AD that is Enabled" -DeletedLogDays "30"
```

```PowerShell
Start-Log "\\LogShare$\ADUsers" "ListOfAdUsers" "BLIT" "Find all users in our AD that is Enabled" "30"
```

![alt text](Images/Start-Log.png?raw=true)

### Write-Log
When you want to add something to the log, you write **write-log "what needs to happen or what happens"** and it is added to the log file. By default, it automatically sets LogLevet to 1, but if you want to draw attention to something, you can change LogLevel to 2 and the log text will turn yellow. If LogLevel is set to 3, the text turns red, it cut bee used in case of error.

```PowerShell
Write-Log -Message "The information you want in your log" -LogLevel 1
```

```PowerShell
Write-Log -Message "The information you want in your log"
```

#### LogLevel options

| Value | Color     |
|------:|-----------|
|  Blank| Nothing   |
|      1| Nothing   |
|      2| Yellow    |
|      3| Red       |

![alt text](Images/LineColor.png?raw=true)

It is possible to create a very long error message, as there is room to display it if you use (THIS program)

![alt text](Images/Description.png?raw=true)

# Software to view the .log fil
I use CMTrace to view the .log fils, I have a copy of the program her.
![CMTrace](https://learn.microsoft.com/en-us/configmgr/core/support/cmtrace)

# Release Notes

v1.10.1.0
- Full Version

v1.10.1.1
- Bug fix