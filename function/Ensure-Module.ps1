

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
    Ensure-Module -ModuleNames Pester

    Installs the Pester modules if they are not already installed from PSGallery and imports the module or just import if it is already installed.

    .EXAMPLE
    Ensure-Module -ModuleNames Pester, Az, Microsoft.Graph

    Checks if the Pester, Az, and Microsoft.Graph modules are installed. If they are not installed, the function installs them from the default repository (PSGallery) and imports them. 
    If they are already installed, then they are simply imported.

    .EXAMPLE
    Ensure-Module -ModuleNames Pester, Az -Repository MyRepo -Scope AllUsers

    Installs the Pester module from 'MyRepo' and makes it available for all users.

    .NOTES
    Author: Benni Ladevig Pedersen
    Version: 1.1.0.0
    #>

    param(
        [string[]]$ModuleName,
        [string]$Repository = "PSGallery",
        [string]$Scope = "CurrentUser"
    )

    
    # Liste over moduler, der ikke kan installeres fra PowerShell Gallery
    $NonGalleryModules = @(
        @{ Name = "ActiveDirectory"; Explanation = "Part of RSAT or Windows features. Install with: Install-WindowsFeature -Name 'RSAT-AD-PowerShell'" },
        @{ Name = "DnsClient"; Explanation = "Built into Windows for DNS configuration and management. Cannot be installed from PowerShell Gallery." },
        @{ Name = "NetTCPIP"; Explanation = "Used for network configuration. Built into Windows." },
        @{ Name = "Storage"; Explanation = "Manages storage pools and volumes. Part of Windows features." },
        @{ Name = "PrintManagement"; Explanation = "For print server administration. Install with RSAT: `Install-WindowsFeature -Name 'RSAT-Print-Services'`." },
        @{ Name = "Hyper-V"; Explanation = "Virtualization management. Install with: `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All`." },
        @{ Name = "FailoverClusters"; Explanation = "Management of Failover Clusters. Install with: `Install-WindowsFeature -Name 'RSAT-Clustering'`." },
        @{ Name = "Defender"; Explanation = "For managing Microsoft Defender. Built into Windows." },
        @{ Name = "DirectAccessClientComponents"; Explanation = "For DirectAccess management. Install as part of RSAT." },
        @{ Name = "RemoteDesktop"; Explanation = "For Remote Desktop Services (RDS) administration. Part of Windows Server." },
        @{ Name = "ServerManager"; Explanation = "For managing Windows Server roles and features. Built into Windows Server." },
        @{ Name = "NFS"; Explanation = "For managing Network File System (NFS). Install as a Windows feature." },
        @{ Name = "WindowsUpdate"; Explanation = "For managing Windows Update. Built into Windows." },
        @{ Name = "GroupPolicy"; Explanation = "For managing Group Policies. Install with RSAT: `Install-WindowsFeature -Name 'RSAT-Group-Policy'`." },
        @{ Name = "NetworkLoadBalancingClusters"; Explanation = "Management of Network Load Balancing (NLB) Clusters. Install with: `Install-WindowsFeature -Name 'RSAT-NLB'`." },
        @{ Name = "BitsTransfer"; Explanation = "Used for Background Intelligent Transfer Service (BITS). Built into Windows." },
        @{ Name = "AppLocker"; Explanation = "For managing AppLocker policies. Part of Windows features." },
        @{ Name = "DHCPServer"; Explanation = "For managing DHCP servers. Install with: `Install-WindowsFeature -Name 'RSAT-DHCP'`." },
        @{ Name = "ADCSAdministration"; Explanation = "For managing Active Directory Certificate Services (ADCS). Install with: `Install-WindowsFeature -Name 'ADCS-AdminTools'`." },
        @{ Name = "WebAdministration"; Explanation = "For IIS administration. Install as a Windows feature." },
        @{ Name = "IISAdministration"; Explanation = "Modern IIS management module. Install with: `Install-WindowsFeature -Name 'Web-Mgmt-Service'`." },
        @{ Name = "WINS"; Explanation = "For WINS administration. Install as part of Windows Server." },
        @{ Name = "IPAMServer"; Explanation = "For IP Address Management (IPAM). Install as part of RSAT." },
        @{ Name = "WindowsServerBackup"; Explanation = "For managing Windows Server Backup. Install with: `Install-WindowsFeature -Name 'Windows-Server-Backup'`." },
        @{ Name = "BranchCache"; Explanation = "For configuring BranchCache. Install with: `Install-WindowsFeature -Name 'BranchCache'`." },
        @{ Name = "RemoteAccess"; Explanation = "For managing Remote Access services like VPN and DirectAccess. Part of RSAT." },
        @{ Name = "ADDSDeployment"; Explanation = "For managing ADDS deployment. Install as a Windows feature." },
        @{ Name = "ADDSAdministration"; Explanation = "For managing and administering ADDS. Install as a Windows feature." },
        @{ Name = "RDS"; Explanation = "For managing Remote Desktop Services (RDS). Install as part of Windows Server." },
        @{ Name = "WindowsAutopilot"; Explanation = "For managing Windows Autopilot services. Part of Windows administration tools." },
        @{ Name = "FSRM"; Explanation = "For managing File Server Resource Manager (FSRM). Install with: `Install-WindowsFeature -Name 'FS-Resource-Manager'`." },
        @{ Name = "ClusterAwareUpdating"; Explanation = "For Cluster-Aware Updating (CAU) on Failover Clusters. Install as part of RSAT." },
        @{ Name = "NetworkController"; Explanation = "For managing Software Defined Networking (SDN). Install as part of Windows Server." },
        @{ Name = "RemoteDesktopServices"; Explanation = "For managing Remote Desktop Services (RDS). Part of Windows Server." },
        @{ Name = "WindowsSearch"; Explanation = "For configuring and managing Windows Search services. Built into Windows." },
        @{ Name = "SmbShare"; Explanation = "For managing SMB file sharing. Built into Windows Server." },
        @{ Name = "SmbWitness"; Explanation = "For SMB Witness services on failover clusters. Part of Windows Server." },
        @{ Name = "BestPractices"; Explanation = "For running Best Practices Analyzer (BPA). Install with: `Install-WindowsFeature -Name 'BestPractices'`." },
        @{ Name = "Kds"; Explanation = "Key Distribution Services (KDS) for distributed AD services. Part of Windows Server." },
        @{ Name = "WindowsServerBackup"; Explanation = "For managing Windows Server Backup. Install with: `Install-WindowsFeature -Name 'Windows-Server-Backup'`." },
        @{ Name = "HyperVFailoverCluster"; Explanation = "For managing Hyper-V Failover Cluster. Install with: `Install-WindowsFeature -Name 'RSAT-Hyper-V-Tools'`." },
        @{ Name = "ADFS"; Explanation = "For managing Active Directory Federation Services (ADFS). Install with: `Install-WindowsFeature -Name 'RSAT-ADFS'`." },
        @{ Name = "DnsServer"; Explanation = "For managing DNS servers. Install with: `Install-WindowsFeature -Name 'RSAT-DNS-Server'`." },
        @{ Name = "WDS"; Explanation = "Windows Deployment Services (WDS) for PXE boot and Windows installation. Install with: `Install-WindowsFeature -Name 'WDS'`." },
        @{ Name = "FileServer"; Explanation = "For managing file servers. Install with: `Install-WindowsFeature -Name 'FS-FileServer'`." }
    )

    foreach ($ModuleName in $ModuleNames) {
        $nonGalleryModule = $NonGalleryModules | Where-Object { $_.Name -eq $ModuleName }
        
        if ($nonGalleryModule) {
            Write-Host "Module '$ModuleName' cannot be installed from PowerShell Gallery. $($nonGalleryModule.Explanation)" -ForegroundColor Yellow
            continue
        }

        $Exist = Find-Module -Name $ModuleName -Repository $Repository

        if ($Exist) {
            if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
                try {
                    Write-Host "Installing module '$ModuleName' from $Repository" -ForegroundColor Green
                    Install-Module -Name $ModuleName -Force -Scope $Scope -Repository $Repository
                } catch {
                    Write-Host "Error installing module '$ModuleName': $_" -ForegroundColor Red
                    continue
                }
            }

            try {
                Import-Module -Name $ModuleName -ErrorAction Stop
                Write-Host "Module '$ModuleName' has been imported." -ForegroundColor Green
            } catch {
                Write-Host "Error importing module '$ModuleName': $_" -ForegroundColor Red
            }
        } else {
            Write-Host "Module '$ModuleName' is not available in $Repository" -ForegroundColor Yellow
        }
    }
}

Export-ModuleMember -Function Ensure-Module