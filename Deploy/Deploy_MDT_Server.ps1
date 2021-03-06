﻿$Modules    = @(
    @{
       Name    = "xSmbShare"
       Version = "2.0.0.0"
    },
    @{
       Name    = "cNtfsAccessControl"
       Version = "1.3.0"
    }
)

Configuration DeployMDTServerContract
{
    Param(
        [Parameter(Mandatory=$true, HelpMessage = "Enter password for MDT Local Account")]
        [PSCredential]$Credentials
    )

    Import-Module -Name PSDesiredStateConfiguration, xSmbShare, cNtfsAccessControl, cMDTBuildLab
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xSmbShare
    Import-DscResource -ModuleName cNtfsAccessControl
    Import-DscResource -ModuleName cMDTBuildLab

    node $AllNodes.Where{$_.Role -match "MDT Server"}.NodeName
    {
        LocalConfigurationManager {
            RebootNodeIfNeeded             = $AllNodes.RebootNodeIfNeeded
            ConfigurationMode              = $AllNodes.ConfigurationMode   
            ConfigurationModeFrequencyMins = $AllNodes.ConfigurationModeFrequencyMins
            RefreshFrequencyMins           = $AllNodes.RefreshFrequencyMins
        }

        cMDTBuildPreReqs MDTPreReqs {
            Ensure       = "Present"            
            DownloadPath = $Node.SourcePath
        }

        User MDTAccessAccount {
            Ensure                 = "Present"
            UserName               = $Credentials.UserName
            FullName               = $Credentials.UserName
            Password               = $Credentials
            PasswordChangeRequired = $false
            PasswordNeverExpires   = $true
            Description            = "Managed Client Administrator Account"
            Disabled               = $false
        }

        WindowsFeature  DataDeduplication {
            Ensure = "Present"
            Name   = "FS-Data-Deduplication"
        }

        Package ADK {
            Ensure     = "Present"
            Name       = "Windows Assessment and Deployment Kit - Windows 10"
            Path       = "$($Node.SourcePath)\Windows Assessment and Deployment Kit\adksetup.exe"
            ProductId  = "39ebb79f-797c-418f-b329-97cfdf92b7ab"
            Arguments  = "/quiet /features OptionId.DeploymentTools OptionId.WindowsPreinstallationEnvironment"
            ReturnCode = 0
        }

        Package MDT {
            Ensure     = "Present"
            Name       = "Microsoft Deployment Toolkit (6.3.8443.1000)"
            Path       = "$($Node.SourcePath)\Microsoft Deployment Toolkit\MicrosoftDeploymentToolkit_x64.msi"
            ProductId  = "9547DE37-4A70-4194-97EA-ACC3E747254B"
            ReturnCode = 0
        }

        cMDTBuildDirectory DeploymentFolder {
            Ensure    = "Present"
            Name      = $Node.PSDrivePath.Replace("$($Node.PSDrivePath.Substring(0,2))\","")
            Path      = $Node.PSDrivePath.Substring(0,2)
            DependsOn = "[Package]MDT"
        }

        xSmbShare FolderDeploymentShare {
            Ensure                = "Present"
            Name                  = $Node.PSDriveShareName
            Path                  = $Node.PSDrivePath
            #FullAccess            = "$($Node.NodeName)\$($Credentials.UserName)"
            FullAccess            = "Everyone"
            FolderEnumerationMode = "AccessBased"
            DependsOn             = "[cMDTBuildDirectory]DeploymentFolder"
        }

        cMDTBuildPersistentDrive DeploymentPSDrive {
            Ensure      = "Present"
            Name        = $Node.PSDriveName
            Path        = $Node.PSDrivePath
            Description = $Node.PSDrivePath.Replace("$($Node.PSDrivePath.Substring(0,2))\","")
            NetworkPath = "\\$($Node.NodeName)\$($Node.PSDriveShareName)"
            DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
        }

        ForEach ($OSDirectory in $Node.OSDirectories) {
            [string]$Ensure    = ""
            [string]$OSVersion = ""
            $OSDirectory.GetEnumerator() | % {
                If ($_.key -eq "Ensure")          { $Ensure    = $_.value }
                If ($_.key -eq "OperatingSystem") { $OSVersion = $_.value }
            }

            cMDTBuildDirectory $OSVersion.Replace(' ','') {
                Ensure      = $Ensure
                Name        = $OSVersion
                Path        = "$($Node.PSDriveName):\Operating Systems"
                PSDriveName = $Node.PSDriveName
                PSDrivePath = $Node.PSDrivePath
                DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
            }

            cMDTBuildDirectory "TS$($OSVersion.Replace(' ',''))" {
                Ensure      = $Ensure
                Name        = $OSVersion
                Path        = "$($Node.PSDriveName):\Task Sequences"
                PSDriveName = $Node.PSDriveName
                PSDrivePath = $Node.PSDrivePath
                DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
            }
        }

        # Task Sequence folder for autobuild
        cMDTBuildDirectory "TSREF" {
            Ensure      = "Present"
            Name        = "REF"
            Path        = "$($Node.PSDriveName):\Task Sequences"
            PSDriveName = $Node.PSDriveName
            PSDrivePath = $Node.PSDrivePath
            DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
        }

        ForEach ($PkgFolder in $Node.PackagesFolderStructure) {
            [string]$Ensure = ""
            [string]$Folder = ""
            $PkgFolder.GetEnumerator() | % {
                If ($_.key -eq "Ensure") { $Ensure = $_.value }
                If ($_.key -eq "Folder") { $Folder = $_.value }
            }

            cMDTBuildDirectory "PKG$($Folder.Replace(' ',''))" {
                Ensure      = $Ensure
                Name        = $Folder
                Path        = "$($Node.PSDriveName):\Packages"
                PSDriveName = $Node.PSDriveName
                PSDrivePath = $Node.PSDrivePath
                DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
            }
        }

        ForEach ($CurrentApplicationFolder in $Node.ApplicationFolderStructure) {
            [string]$EnsureApplicationFolder = ""
            [string]$ApplicationFolder       = ""
            $CurrentApplicationFolder.GetEnumerator() | % {
                If ($_.key -eq "Ensure") { $EnsureApplicationFolder = $_.value }
                If ($_.key -eq "Folder") { $ApplicationFolder       = $_.value }
            }

            cMDTBuildDirectory "AF$($ApplicationFolder.Replace(' ',''))" {
                Ensure      = $EnsureApplicationFolder
                Name        = $ApplicationFolder
                Path        = "$($Node.PSDriveName):\Applications"
                PSDriveName = $Node.PSDriveName
                PSDrivePath = $Node.PSDrivePath
                DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
            }

            ForEach ($CurrentApplicationSubFolder in $CurrentApplicationFolder.SubFolders) {
                [string]$EnsureApplicationSubFolder = ""
                [string]$ApplicationSubFolder       = ""
                $CurrentApplicationSubFolder.GetEnumerator() | % {
                    If ($_.key -eq "Ensure")    { $EnsureApplicationSubFolder = $_.value }
                    If ($_.key -eq "SubFolder") { $ApplicationSubFolder       = $_.value }
                }

                cMDTBuildDirectory "ASF$($ApplicationSubFolder.Replace(' ',''))" {
                    Ensure      = $EnsureApplicationSubFolder
                    Name        = $ApplicationSubFolder
                    Path        = "$($Node.PSDriveName):\Applications\$ApplicationFolder"
                    PSDriveName = $Node.PSDriveName
                    PSDrivePath = $Node.PSDrivePath
                    DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
                }
            }
        }

        ForEach ($SelectionProfile in $Node.SelectionProfiles) {
            [string]$Ensure      = ""
            [string]$Name        = ""
            [string]$Comments    = ""
            [string]$IncludePath = ""
            $SelectionProfile.GetEnumerator() | % {
                If ($_.key -eq "Ensure")      { $Ensure      = $_.value }
                If ($_.key -eq "Name")        { $Name        = $_.value }
                If ($_.key -eq "Comments")    { $Comments    = $_.value }
                If ($_.key -eq "IncludePath") { $IncludePath = $_.value }
            }

            cMDTBuildSelectionProfile $Name.Replace(' ','') {
                Ensure      = $Ensure
                Name        = $Name
                Comments    = $Comments
                IncludePath = $IncludePath
                PSDriveName = $Node.PSDriveName
                PSDrivePath = $Node.PSDrivePath
                DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
            }
        }

        ForEach ($OperatingSystem in $Node.OperatingSystems) {
            [string]$Ensure     = ""
            [string]$Name       = ""
            [string]$Path       = ""
            [string]$SourcePath = ""

            $OperatingSystem.GetEnumerator() | % {
                If ($_.key -eq "Ensure")     { $Ensure     = $_.value }
                If ($_.key -eq "Name")       { $Name       = $_.value }
                If ($_.key -eq "Path")       { $Path       = "$($Node.PSDriveName):\Operating Systems\$($_.value)" }
                If ($_.key -eq "SourcePath") { $SourcePath = "$($Node.SourcePath)$($_.value)" }
            }

            cMDTBuildOperatingSystem $Name.Replace(' ','') {
                Ensure      = $Ensure
                Name        = $Name
                Path        = $Path
                SourcePath  = $SourcePath
                PSDriveName = $Node.PSDriveName
                PSDrivePath = $Node.PSDrivePath
                DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
            }
        }

        ForEach ($Application in $Node.Applications) {
            [string]$Ensure                = ""
            [string]$Name                  = ""
            [string]$Path                  = ""
            [string]$CommandLine           = ""
            [string]$ApplicationSourcePath = ""

            $Application.GetEnumerator() | % {
                If ($_.key -eq "Ensure")                { $Ensure                = $_.value }
                If ($_.key -eq "Name")                  { $Name                  = $_.value }
                If ($_.key -eq "Path")                  { $Path                  = "$($Node.PSDriveName):$($_.value)" }
                If ($_.key -eq "CommandLine")           { $CommandLine           = $_.value }
                If ($_.key -eq "ApplicationSourcePath") { $ApplicationSourcePath = "$($Node.SourcePath)\$($_.value)" }
            }

            cMDTBuildApplication $Name.Replace(' ','') {
                Ensure                = $Ensure
                Name                  = $Name
                Path                  = $Path
                CommandLine           = $CommandLine
                ApplicationSourcePath = $ApplicationSourcePath
                Enabled               = "True"
                PSDriveName           = $Node.PSDriveName
                PSDrivePath           = $Node.PSDrivePath
                DependsOn             = "[cMDTBuildDirectory]DeploymentFolder"
            }
        }

        ForEach ($Package in $Node.Packages) {
            [string]$Ensure            = ""
            [string]$Name              = ""
            [string]$Path              = ""
            [string]$PackageSourcePath = ""

            $Package.GetEnumerator() | % {
                If ($_.key -eq "Ensure")            { $Ensure            = $_.value }
                If ($_.key -eq "Name")              { $Name              = $_.value }
                If ($_.key -eq "Path")              { $Path              = "$($Node.PSDriveName):$($_.value)" }
                If ($_.key -eq "PackageSourcePath") { $PackageSourcePath = "$($Node.SourcePath)\$($_.value)" }
            }

            cMDTBuildPackage $Name.Replace(' ','') {
                Ensure            = $Ensure
                Name              = $Name
                Path              = $Path
                PackageSourcePath = $PackageSourcePath
                PSDriveName       = $Node.PSDriveName
                PSDrivePath       = $Node.PSDrivePath
                DependsOn         = "[cMDTBuildDirectory]DeploymentFolder"
            }
        }

        ForEach ($TaskSequence in $Node.TaskSequences) {
            [string]$Ensure   = ""
            [string]$Name     = ""
            [string]$Path     = ""
            [string]$OSName   = ""
            [string]$Template = ""
            [string]$ID       = ""
            [string]$OrgName  = ""

            $TaskSequence.GetEnumerator() | % {
                If ($_.key -eq "Ensure")   { $Ensure   = $_.value }
                If ($_.key -eq "Name")     { $Name     = $_.value }
                If ($_.key -eq "Path")     { $Path     = "$($Node.PSDriveName):\Task Sequences\$($_.value)" }
                If ($_.key -eq "OSName")   { $OSName   = "$($Node.PSDriveName):\Operating Systems\$($_.value)" }
                If ($_.key -eq "Template") { $Template = $_.value }
                If ($_.key -eq "ID")       { $ID       = $_.value }
                If ($_.key -eq "OrgName")  { $OrgName  = $_.value }
            }

            # Create Task Sequence for one OS image
            cMDTBuildTaskSequence $Name.Replace(' ','') {
                Ensure      = $Ensure
                Name        = $Name
                Path        = $Path
                OSName      = $OSName
                Template    = $Template
                ID          = $ID
                OrgName     = $OrgName
                PSDriveName = $Node.PSDriveName
                PSDrivePath = $Node.PSDrivePath
                DependsOn   = "[cMDTBuildDirectory]DeploymentFolder"
            }

            # Customize Task Sequence for one OS image
            ForEach ($TSCustomize in $TaskSequence.Customize) {
                [string]$Name             = ""
                [string]$NewName          = ""
                [string]$Type             = ""
                [string]$GroupName        = ""
                [string]$SubGroup         = ""
                [string]$Disable          = ""
                [string]$AddAfter         = ""
                [string]$Description      = ""
                [string]$TSVarName        = ""    # for MDT variable only
                [string]$TSVarValue       = ""    # for MDT variable only
                [string]$OSName           = ""    # for OS features only
                [string]$OSFeatures       = ""    # for OS features only
                [string]$Command          = ""    # for Run Command line only
                [string]$StartIn          = ""    # for Run Command line only
                [string]$SelectionProfile = ""    # for Install Updates Offline only

                $TSCustomize.GetEnumerator() | % {
                    If ($_.key -eq "Name")             { $Name             = $_.value }
                    If ($_.key -eq "NewName")          { $NewName          = $_.value }
                    If ($_.key -eq "Type")             { $Type             = $_.value }
                    If ($_.key -eq "GroupName")        { $GroupName        = $_.value }
                    If ($_.key -eq "SubGroup")         { $SubGroup         = $_.value }
                    If ($_.key -eq "Disable")          { $Disable          = $_.value }
                    If ($_.key -eq "AddAfter")         { $AddAfter         = $_.value }
                    if ($_.key -eq "Description")      { $Description      = $_.value }
                    if ($_.key -eq "TSVarName")        { $TSVarName        = $_.value }
                    if ($_.key -eq "TSVarValue")       { $TSVarValue       = $_.value }
                    If ($_.key -eq "OSName")           { $OSName           = $_.value }
                    If ($_.key -eq "OSFeatures")       { $OSFeatures       = $_.value }
                    If ($_.key -eq "Command")          { $Command          = $_.value }
                    If ($_.key -eq "StartIn")          { $StartIn          = $_.value }
                    If ($_.key -eq "SelectionProfile") { $SelectionProfile = $_.value }
                }

                # Current TS XML file name
                $TSFile = "$($Node.PSDrivePath)\Control\$($ID)\ts.xml"

                $CustomResource = $ID + '-' + $Name.Replace(' ','')
                cMDTBuildTaskSequenceCustomize $CustomResource {
                    TSFile           = $TSFile
                    Name             = $Name
                    NewName          = $NewName
                    Type             = $Type
                    GroupName        = $GroupName
                    SubGroup         = $SubGroup
                    Disable          = $Disable
                    AddAfter         = $AddAfter
                    Description      = $Description
                    TSVarName        = $TSVarName
                    TSVarValue       = $TSVarValue
                    OSName           = $OSName
                    OSFeatures       = $OSFeatures
                    Command          = $Command
                    StartIn          = $StartIn
                    SelectionProfile = $SelectionProfile
                    PSDriveName      = $Node.PSDriveName
                    PSDrivePath      = $Node.PSDrivePath
                }
            }
        }

        ForEach ($CustomSetting in $Node.CustomSettings) {
            [string]$Ensure      = ""
            [string]$Name        = ""
            [string]$SourcePath  = ""
            [string[]]$TestFiles = ""

            $CustomSetting.GetEnumerator() | % {
                If ($_.key -eq "Ensure")     { $Ensure     = $_.value }
                If ($_.key -eq "Name")       { $Name       = $_.value }
                If ($_.key -eq "SourcePath") { $SourcePath = "$($Node.SourcePath)\$($_.value)" }
                If ($_.key -eq "TestFiles")  { $TestFiles  = $_.value }
            }

            cMDTBuildCustomize $Name.Replace(' ','') {
                Ensure       = $Ensure
                Name         = $Name
                SourcePath   = $SourcePath
                Path         = $Node.PSDrivePath
                TestFiles    = $TestFiles
                DependsOn    = "[cMDTBuildDirectory]DeploymentFolder"
            }
        }

        ForEach ($IniFile in $Node.CustomizeIniFiles) {
            [string]$Ensure         = ""
            [string]$Name           = ""
            [string]$Path           = ""
            [string]$Company        = ""
            [string]$TimeZomeName   = ""
            [string]$WSUSServer     = ""
            [string]$UserLocale     = ""
            [string]$KeyboardLocale = ""

            $IniFile.GetEnumerator() | % {
                If ($_.key -eq "Ensure")         { $Ensure         = $_.value }
                If ($_.key -eq "Name")           { $Name           = $_.value }
                If ($_.key -eq "Path")           { $Path           = "$($Node.PSDrivePath)$($_.value)" }                                                
                If ($_.key -eq "Company")        { $Company        = $_.value }
                If ($_.key -eq "TimeZoneName")   { $TimeZoneName   = $_.value }
                If ($_.key -eq "WSUSServer")     { $WSUSServer     = $_.value }
                If ($_.key -eq "UserLocale")     { $UserLocale     = $_.value }
                If ($_.key -eq "KeyboardLocale") { $KeyboardLocale = $_.value }
            }

            If ($Company)        { $Company        = "_SMSTSORGNAME=$($Company)" }         Else { $Company        = ";_SMSTSORGNAME=" }
            If ($TimeZoneName)   { $TimeZoneName   = "TimeZoneName=$($TimeZoneName)" }     Else { $TimeZoneName   = ";TimeZoneName=" }
            If ($WSUSServer)     { $WSUSServer     = "WSUSServer=$($WSUSServer)" }         Else { $WSUSServer     = ";WSUSServer=" }
            If ($UserLocale)     { $UserLocale     = "UserLocale=$($UserLocale)" }         Else { $UserLocale     = ";UserLocale=" }
            If ($KeyboardLocale) { $KeyboardLocale = "KeyboardLocale=$($KeyboardLocale)" } Else { $KeyboardLocale = ";KeyboardLocale=" }

            If ($Name -eq "CustomSettingsIni") {
                cMDTBuildCustomSettingsIni ini {
                    Ensure    = $Ensure
                    Path      = $Path
                    DependsOn = "[cMDTBuildDirectory]DeploymentFolder"
                    Content   = @"
[Settings]
Priority=Serialnumber,Default

[Default]
$($Company)
OSInstall=Y
HideShell=YES
ApplyGPOPack=NO
UserDataLocation=NONE
DoNotCreateExtraPartition=YES
JoinWorkgroup=WORKGROUP
$($TimeZoneName)
$($WSUSServer)
;SLShare=%DeployRoot%\Logs
FinishAction=SHUTDOWN

;Set keyboard layout
$($UserLocale)
$($KeyboardLocale)

;Exclude updates that are already included in W7 Convenience update, but flagged incorrectly on Microsoft Update
WUMU_ExcludeKB1=2965788
WUMU_ExcludeKB2=2984976
WUMU_ExcludeKB3=3126446
WUMU_ExcludeKB4=3075222
WUMU_ExcludeKB5=3069762
WUMU_ExcludeKB6=3036493
WUMU_ExcludeKB7=3067904
WUMU_ExcludeKB8=3035017
WUMU_ExcludeKB9=3003743
WUMU_ExcludeKB10=3039976
WUMU_ExcludeKB11=2862330
WUMU_ExcludeKB12=2529073

ComputerBackupLocation=NETWORK
BackupShare=\\$($Node.NodeName)\$($Node.PSDriveShareName)
BackupDir=Captures
;BackupFile=#left("%TaskSequenceID%", len("%TaskSequenceID%")-3) & year(date) & right("0" & month(date), 2) & right("0" & day(date), 2)#.wim
;DoCapture=YES

;Disable all wizard pages
SkipAdminPassword=YES
SkipApplications=YES
SkipBitLocker=YES
SkipComputerBackup=YES
SkipComputerName=YES
SkipDomainMembership=YES
SkipFinalSummary=YES
SkipLocaleSelection=YES
SkipPackageDisplay=YES
SkipProductKey=YES
SkipRoles=YES
SkipSummary=YES
SkipTimeZone=YES
SkipUserData=YES
SkipTaskSequence=NO
SkipCapture=NO
"@
                }
            }

            If ($Name -eq "BootstrapIni") {
                cMDTBuildBootstrapIni ini {
                    Ensure    = $Ensure
                    Path      = $Path
                    DependsOn = "[cMDTBuildDirectory]DeploymentFolder"
                    Content   = @"
[Settings]
Priority=Default

[Default]
DeployRoot=\\$($Node.NodeName)\$($Node.PSDriveShareName)
SkipBDDWelcome=YES

;MDT Connect Account
UserID=$($Credentials.UserName)
UserPassword=$($Credentials.GetNetworkCredential().password)
UserDomain=$($Node.NodeName)
"@
                }
            }
        }

        ForEach ($Image in $Node.BootImage) {
            [string]$Version                  = ""
            [string]$ExtraDirectory           = ""
            [string]$BackgroundFile           = ""
            [string]$LiteTouchWIMDescription  = ""

            $Image.GetEnumerator() | % {
                If ($_.key -eq "Version")                  { $Version                  = $_.value }
                If ($_.key -eq "ExtraDirectory")           { $ExtraDirectory           = $_.value }
                If ($_.key -eq "BackgroundFile")           { $BackgroundFile           = $_.value }
                If ($_.key -eq "LiteTouchWIMDescription")  { $LiteTouchWIMDescription  = $_.value }
            }

            cMDTBuildUpdateBootImage updateBootImage {
                Version                 = $Version
                PSDeploymentShare       = $Node.PSDriveName
                PSDrivePath             = $Node.PSDrivePath
                ExtraDirectory          = $ExtraDirectory
                BackgroundFile          = $BackgroundFile
                LiteTouchWIMDescription = $LiteTouchWIMDescription
                DependsOn               = "[cMDTBuildDirectory]DeploymentFolder"
            }
        }

        cNtfsPermissionEntry AssignPermissionsMDT {
            Ensure = "Present"
            Path   = $Node.PSDrivePath
            Principal  = "$($Node.NodeName)\$($Credentials.UserName)"
            AccessControlInformation = @(
                cNtfsAccessControlInformation {
                    AccessControlType = "Allow"
                    FileSystemRights = "ReadAndExecute"
                    Inheritance = "ThisFolderSubfoldersAndFiles"
                    NoPropagateInherit = $false
                }
            )
            DependsOn  = "[cMDTBuildPersistentDrive]DeploymentPSDrive"
        }

        cNtfsPermissionEntry AssignPermissionsCaptures {
            Ensure = "Present"
            Path   = "$($Node.PSDrivePath)\Captures"
            Principal  = "$($Node.NodeName)\$($Credentials.UserName)"
            AccessControlInformation = @(
                cNtfsAccessControlInformation {
                    AccessControlType = "Allow"
                    FileSystemRights = "Modify"
                    Inheritance = "ThisFolderSubfoldersAndFiles"
                    NoPropagateInherit = $false
                }
            )
            DependsOn  = "[cMDTBuildPersistentDrive]DeploymentPSDrive"
        }
    }
}

#Get password for MDT Local Account
$Cred = Get-Credential -UserName SVCMDTConnect001 -Message "Enter password for Local MDT Account"

#Get configuration data
#$ConfigurationData = Invoke-Expression (Get-Content -Path "$PSScriptRoot\Deploy_MDT_Server_ConfigurationData_Lite.psd1" -Raw) # Only Windows 10 x86 Evaluation
$ConfigurationData = Invoke-Expression (Get-Content -Path "$PSScriptRoot\Deploy_MDT_Server_ConfigurationData.psd1" -Raw)       # Full

#Create DSC MOF job
DeployMDTServerContract -OutputPath "$PSScriptRoot\MDT-Deploy_MDT_Server" -ConfigurationData $ConfigurationData -Credentials $Cred

#Set DSC LocalConfigurationManager
$winrmArgs = 'set winrm/config @{MaxEnvelopeSizekb="8192"}'
start-process "winrm" -ArgumentList $winrmArgs -NoNewWindow
Set-DscLocalConfigurationManager -Path "$PSScriptRoot\MDT-Deploy_MDT_Server" -Verbose

#Start DSC MOF job
Start-DscConfiguration -Wait -Force -Verbose -ComputerName "$env:computername" -Path "$PSScriptRoot\MDT-Deploy_MDT_Server"

#Set data deduplication
Enable-DedupVolume -Volume "E:"
Set-DedupVolume -Volume "E:" -MinimumFileAgeDays 1

Write-Output ""
Write-Output "Deploy MDT Server Builder completed!"
