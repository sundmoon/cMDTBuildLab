@{

# Script module or binary module file associated with this manifest.
RootModule = 'cMDTBuildLab.psm1'

DscResourcesToExport = @('cMDTBuildApplication','cMDTBuildBootstrapIni','cMDTBuildCustomize','cMDTBuildCustomSettingsIni','cMDTBuildDirectory','cMDTBuildOperatingSystem','cMDTBuildPackage','cMDTBuildPersistentDrive','cMDTBuildPreReqs','cMDTBuildSelectionProfile','cMDTBuildTaskSequence','cMDTBuildTaskSequenceCustomize','cMDTBuildUpdateBootImage')

FunctionsToExport  = @('Import-MicrosoftDeploymentToolkitModule','Invoke-ExpandArchive','Invoke-RemovePath','Invoke-TestPath')

# Version number of this module.
ModuleVersion = '0.9.3'

# ID used to uniquely identify this module
GUID = 'df45de26-88b1-4a95-98af-b798fde1424f'

# Author of this module
Author = 'Pavel Andreev'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = '(c) 2016 Pavel Andreev. All rights reserved.'

# Description of the functionality provided by this module
Description = 'A DSC Module to help automize deployment Windows Reference Images on MDT Server'

# Project site link
HelpInfoURI = 'https://github.com/pvs043/cMDTBuildLab/wiki'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @('xSmbShare', 'cNtfsAccessControl')

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResource', 'MDT', 'Deploy')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/pvs043/cMDTBuildLab/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/pvs043/cMDTBuildLab'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '
 * Windows 7 Update Client: replace KB3138612 for KB3172605
 * Customsettings.ini changes: Exclude updates that are already included in W7 Convenience update, but flagged incorrectly on Microsoft Update
 * Cumulative update for Windows 10 Version 1607 and Windows Server 2016: January 10, 2017 (KB3213986)
 * Do not download and install KB3199986 as prerequisite for Windows 10 Cumulative update
'
    } # End of PSData hashtable

} # End of PrivateData hashtable

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''
}
