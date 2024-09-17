


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
    Version: 1.0.0.2
    #>

    param(
        [string]$ModuleName,
        [string]$Repository = "PSGallery",
        [string]$Scope = "CurrentUser"
    )

    
    # Liste over moduler, der ikke kan installeres fra PowerShell Gallery
    $NonGalleryModules = @(
        @{ Name = "ActiveDirectory"; Explanation = "Del af RSAT eller Windows-features. Installér med: Install-WindowsFeature -Name 'RSAT-AD-PowerShell'" },
        @{ Name = "DnsClient"; Explanation = "Indbygget i Windows for DNS-konfiguration og -administration. Ingen installation fra PowerShell Gallery." },
        @{ Name = "NetTCPIP"; Explanation = "Bruges til netværkskonfiguration. Indbygget i Windows." },
        @{ Name = "Storage"; Explanation = "Administrerer storage pools og diskenheder. Del af Windows-funktioner." },
        @{ Name = "PrintManagement"; Explanation = "Til printserveradministration. Installér med RSAT: `Install-WindowsFeature -Name 'RSAT-Print-Services'`." },
        @{ Name = "Hyper-V"; Explanation = "Virtualiseringsstyring. Installér med: `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All`." },
        @{ Name = "FailoverClusters"; Explanation = "Styring af Failover Clusters. Installér med: `Install-WindowsFeature -Name 'RSAT-Clustering'`." },
        @{ Name = "Defender"; Explanation = "Til styring af Microsoft Defender. Indbygget i Windows." },
        @{ Name = "DirectAccessClientComponents"; Explanation = "Til DirectAccess-administration. Installér som en del af RSAT." },
        @{ Name = "RemoteDesktop"; Explanation = "Til administration af Remote Desktop Services (RDS). Del af Windows Server." },
        @{ Name = "ServerManager"; Explanation = "Til styring af Windows Server-roller og -funktioner. Indbygget i Windows Server." },
        @{ Name = "NFS"; Explanation = "Til styring af Network File System (NFS). Installér som Windows-feature." },
        @{ Name = "WindowsUpdate"; Explanation = "Til administration af Windows Update. Indbygget i Windows." },
        @{ Name = "GroupPolicy"; Explanation = "Til administration af gruppepolitikker. Installér med RSAT: `Install-WindowsFeature -Name 'RSAT-Group-Policy'`." },
        @{ Name = "NetworkLoadBalancingClusters"; Explanation = "Styring af Network Load Balancing (NLB) Clusters. Installér med: `Install-WindowsFeature -Name 'RSAT-NLB'`." },
        @{ Name = "BitsTransfer"; Explanation = "Bruges til Background Intelligent Transfer Service (BITS). Indbygget i Windows." },
        @{ Name = "AppLocker"; Explanation = "Til styring af AppLocker-politikker. Del af Windows-features." },
        @{ Name = "DHCPServer"; Explanation = "Til administration af DHCP-servere. Installér med: `Install-WindowsFeature -Name 'RSAT-DHCP'`." },
        @{ Name = "ADCSAdministration"; Explanation = "Administration af AD Certificate Services (ADCS). Installér med: `Install-WindowsFeature -Name 'ADCS-AdminTools'`." },
        @{ Name = "WebAdministration"; Explanation = "Til administration af IIS. Installér som Windows-feature." },
        @{ Name = "IISAdministration"; Explanation = "Moderne IIS-administrationsmodul. Installér med: `Install-WindowsFeature -Name 'Web-Mgmt-Service'`." },
        @{ Name = "WINS"; Explanation = "Til WINS-administration. Installér som en del af Windows Server." },
        @{ Name = "IPAMServer"; Explanation = "Til IP Address Management (IPAM). Installér som en del af RSAT." },
        @{ Name = "RemoteAccess"; Explanation = "Til administration af Remote Access-tjenester som VPN og DirectAccess. Del af RSAT." },
        @{ Name = "ADDSDeployment"; Explanation = "Til administration af ADDS-implementering. Installér som Windows-feature." },
        @{ Name = "ADDSAdministration"; Explanation = "Til styring og administration af ADDS. Installér som Windows-feature." },
        @{ Name = "RDS"; Explanation = "Til administration af Remote Desktop Services (RDS). Installér som en del af Windows Server." },
        @{ Name = "WindowsAutopilot"; Explanation = "Til administration af Windows Autopilot-tjenester. Del af Windows-administrationsværktøjer." },
        @{ Name = "FSRM"; Explanation = "Til administration af File Server Resource Manager (FSRM). Installér med: `Install-WindowsFeature -Name 'FS-Resource-Manager'`." },
        @{ Name = "ClusterAwareUpdating"; Explanation = "Til Cluster-Aware Updating (CAU) på Failover Clusters. Installér som en del af RSAT." },
        @{ Name = "NetworkController"; Explanation = "Til administration af Software Defined Networking (SDN). Installér som en del af Windows Server." },
        @{ Name = "RemoteDesktopServices"; Explanation = "Til administration af Remote Desktop Services (RDS). Del af Windows Server." },
        @{ Name = "WindowsSearch"; Explanation = "Til konfiguration og administration af Windows Search-tjenester. Indbygget i Windows." },
        @{ Name = "SmbShare"; Explanation = "Til administration af SMB-fildeling. Indbygget i Windows Server." },
        @{ Name = "SmbWitness"; Explanation = "Til SMB Witness-tjenester på failover-klynger. Del af Windows Server." },
        @{ Name = "BestPractices"; Explanation = "Til kørsel af Best Practices Analyzer (BPA). Installér med: `Install-WindowsFeature -Name 'BestPractices'`." },
        @{ Name = "Kds"; Explanation = "Key Distribution Services (KDS) til distribuerede AD-tjenester. Del af Windows Server." }
        @{ Name = "WindowsServerBackup"; Explanation = "Til administration af Windows Server Backup. Installér med: `Install-WindowsFeature -Name 'Windows-Server-Backup'`." },
        @{ Name = "HyperVFailoverCluster"; Explanation = "Til styring af Hyper-V Failover Cluster. Installér med: `Install-WindowsFeature -Name 'RSAT-Hyper-V-Tools'`." },
        @{ Name = "ADFS"; Explanation = "Til administration af Active Directory Federation Services (ADFS). Installér med: `Install-WindowsFeature -Name 'RSAT-ADFS'`." },
        @{ Name = "DnsServer"; Explanation = "Til styring af DNS-servere. Installér med: `Install-WindowsFeature -Name 'RSAT-DNS-Server'`." },
        @{ Name = "WDS"; Explanation = "Windows Deployment Services (WDS) til PXE-boot og installation af Windows. Installér med: `Install-WindowsFeature -Name 'WDS'`." },
        @{ Name = "FileServer"; Explanation = "Til styring af filservere. Installér med: `Install-WindowsFeature -Name 'FS-FileServer'`." },
        @{ Name = "BranchCache"; Explanation = "Til konfiguration af BranchCache. Installér med: `Install-WindowsFeature -Name 'BranchCache'`." }
    )

    # Tjek om modulet er på listen over dem, der ikke kan installeres fra PowerShell Gallery
    $nonGalleryModule = $NonGalleryModules | Where-Object { $_.Name -eq $ModuleName }
    
    if ($nonGalleryModule) {
        Write-Host "Modulet '$ModuleName' kan ikke installeres fra PowerShell Gallery. $($nonGalleryModule.Explanation)" -ForegroundColor Yellow
        return
    }

    # Tjek om modulet allerede er installeret
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        try {
            # Forsøg at installere modulet fra PowerShell Gallery
            Write-Host "Installerer modulet '$ModuleName' fra $Repository" -ForegroundColor Green
            Install-Module -Name $ModuleName -Force -Scope $Scope -Repository $Repository
        } catch {
            Write-Host "Fejl under installation af modulet '$ModuleName': $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Modulet '$ModuleName' er allerede installeret." -ForegroundColor Cyan
    }

    # Importér modulet, hvis det blev installeret eller allerede var installeret
    try {
        Import-Module -Name $ModuleName -ErrorAction Stop
        Write-Host "Modulet '$ModuleName' er blevet importeret." -ForegroundColor Green
    } catch {
        Write-Host "Fejl under import af modulet '$ModuleName': $_" -ForegroundColor Red
    }
}
