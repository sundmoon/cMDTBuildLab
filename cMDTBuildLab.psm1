enum Ensure
{
    Absent
    Present
}

[DscResource()]
class cMDTBuildApplication
{
    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Key)]
    [string]$Path

    [DscProperty(Mandatory)]
    [string]$Enabled
    
    [DscProperty(Mandatory)]
    [string]$CommandLine
    
    [DscProperty(Mandatory)]
    [string]$ApplicationSourcePath
    
    [DscProperty(Mandatory)]
    [string]$PSDriveName

    [DscProperty(Mandatory)]
    [string]$PSDrivePath

    [void] Set()
    {
        if ($this.ensure -eq [Ensure]::Present) {
            $present = Invoke-TestPath -Path "$($this.path)\$($this.name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath
            if ( !$present ) {
                $this.ImportApplication()
            }
        }
        else {   
            Invoke-RemovePath -Path "$($this.path)\$($this.name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath -Verbose
        }
    }

    [bool] Test()
    {
        $present = Invoke-TestPath -Path "$($this.path)\$($this.name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath 

        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [cMDTBuildApplication] Get()
    {
        return $this
    }

    [void] ImportApplication()
    {
        Import-MicrosoftDeploymentToolkitModule
        New-PSDrive -Name $this.PSDriveName -PSProvider "MDTProvider" -Root $this.PSDrivePath -Verbose:$false
        Import-MDTApplication -Path $this.Path -Enable $this.Enabled -Name $this.Name -ShortName $this.Name `
                              -CommandLine $this.CommandLine -WorkingDirectory ".\Applications\$($this.Name)" `
                              -ApplicationSourcePath $this.ApplicationSourcePath -DestinationFolder $this.Name -Verbose
    }
}

[DscResource()]
class cMDTBuildBootstrapIni
{
    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [DscProperty(Key)]
    [string]$Path

    [DscProperty()]
    [string]$Content

    [void] Set()
    {
        if ($this.Ensure -eq [Ensure]::Present) {
            $this.SetContent()
        }
        else {
            $this.SetDefaultContent()
        }
    }

    [bool] Test()
    {
        $present = $this.TestFileContent()
        
        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [cMDTBuildBootstrapIni] Get()
    {
        return $this
    }

    [bool] TestFileContent()
    {
        $present = $false
        $existingConfiguration = Get-Content -Path $this.Path -Raw #-Encoding UTF8

        if ($existingConfiguration -eq $this.Content.Replace("`n","`r`n")) {
            $present = $true   
        }
        return $present
    }

    [void] SetContent()
    {
        Set-Content -Path $this.Path -Value $this.Content.Replace("`n","`r`n") -NoNewline -Force #-Encoding UTF8 
    }
    
    [void] SetDefaultContent()
    {
        $defaultContent = @"
[Settings]
Priority=Default

[Default]

"@
        Set-Content -Path $this.Path -Value $defaultContent -NoNewline -Force #-Encoding UTF8 
    }
}

[DscResource()]
class cMDTBuildCustomize
{
    [DscProperty(Mandatory)]
    [Ensure]$Ensure
    
    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Key)]
    [string]$Path
    
    [DscProperty(Mandatory)]
    [string]$SourcePath

    [DscProperty(Mandatory)]
    [string[]]$TestFiles

    [DscProperty(NotConfigurable)]
    [string]$Directory

    [void] Set()
    {
        $filename = "$($this.SourcePath)\$($this.Name).zip"
        $extractfolder = "$($this.path)\$($this.name)"

        if ($this.ensure -eq [Ensure]::Present) {
            Invoke-ExpandArchive -Source $filename -Target $extractfolder -Verbose
        }
        else {
            Invoke-RemovePath -Path $extractfolder -Verbose
        }
    }

    [bool] Test()
    {
        $present = $true
        foreach ($file in $this.TestFiles) {
            if ( !(Test-Path -Path "$($this.path)\$($this.name)\$($file)") ) {
                $present = $false
                break
            }
        }

        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [cMDTBuildCustomize] Get()
    {
        return $this
    }
}

[DscResource()]
class cMDTBuildCustomSettingsIni
{
    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [DscProperty(Key)]
    [string]$Path

    [DscProperty()]
    [string]$Content

    [void] Set()
    {
        if ($this.Ensure -eq [Ensure]::Present) {
            $this.SetContent()
        }
        else {
            $this.SetDefaultContent()
        }
    }

    [bool] Test()
    {
        $present = $this.TestFileContent()
        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [cMDTBuildCustomSettingsIni] Get()
    {
        return $this
    }

    [bool] TestFileContent()
    {
        $present = $false 
        $existingConfiguration = Get-Content -Path $this.Path -Raw #-Encoding UTF8
        if ($existingConfiguration -eq $this.Content.Replace("`n","`r`n")) {
            $present = $true   
        }
        return $present
    }

    [void] SetContent()
    {
        Set-Content -Path $this.Path -Value $this.Content.Replace("`n","`r`n") -NoNewline -Force #-Encoding UTF8
    }
    
    [void] SetDefaultContent()
    {
        $defaultContent = @"
[Settings]
Priority=Default
Properties=MyCustomProperty

[Default]
OSInstall=Y
SkipCapture=YES
SkipAdminPassword=NO
SkipProductKey=YES

"@
        Set-Content -Path $this.Path -Value $defaultContent -NoNewline -Force #-Encoding UTF8
    }
}

[DscResource()]
class cMDTBuildDirectory
{
    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [DscProperty(Key)]
    [string]$Path

    [DscProperty(Key)]
    [string]$Name

    [DscProperty()]
    [string]$PSDriveName

    [DscProperty()]
    [string]$PSDrivePath

    [void] Set()
    {
        if ($this.ensure -eq [Ensure]::Present) {
            $this.CreateDirectory()
        }
        else
        {
            if (($this.PSDrivePath) -and ($this.PSDriveName)) {
                Invoke-RemovePath -Path "$($this.path)\$($this.Name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath -Verbose
            }
            else {
                Invoke-RemovePath -Path "$($this.path)\$($this.Name)" -Verbose
            }
        }
    }

    [bool] Test()
    {
        if (($this.PSDrivePath) -and ($this.PSDriveName)) {
            $present = Invoke-TestPath -Path "$($this.path)\$($this.Name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath -Verbose
        }
        else {
            $present = Invoke-TestPath -Path "$($this.path)\$($this.Name)" -Verbose
        }
        
        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [cMDTBuildDirectory] Get()
    {
        return $this
    }

    [void] CreateDirectory()
    {
        if (($this.PSDrivePath) -and ($this.PSDriveName)) {
            Import-MicrosoftDeploymentToolkitModule
            New-PSDrive -Name $this.PSDriveName -PSProvider "MDTProvider" -Root $this.PSDrivePath -Verbose:$false | `
                    New-Item -ItemType Directory -Path "$($this.path)\$($this.Name)" -Verbose
        }
        else {
            New-Item -ItemType Directory -Path "$($this.path)\$($this.Name)" -Verbose
        }
    }
}

[DscResource()]
class cMDTBuildOperatingSystem
{
    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Key)]
    [string]$Path

    [DscProperty(Key)]
    [string]$SourcePath

    [DscProperty(Mandatory)]
    [string]$PSDriveName

    [DscProperty(Mandatory)]
    [string]$PSDrivePath

    [void] Set()
    {
        if ($this.ensure -eq [Ensure]::Present)
        {
            if ( !$this.Test() ) {
                                $this.ImportOperatingSystem("$($this.SourcePath)")
            }
        }
        else
        {
            Invoke-RemovePath -Path "$($this.PSDrivePath)\Operating Systems\$($this.Name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath -Verbose
            If ( $this.Test() ) { Write-Error "Cannot remove '$($this.PSDrivePath)\Operating Systems\$($this.Name)'" }
        }
    }

    [bool] Test()
    {
        $present = Invoke-TestPath -Path "$($this.PSDrivePath)\Operating Systems\$($this.Name)\sources\install.wim"
        return $present
    }

    [cMDTBuildOperatingSystem] Get()
    {
        return $this
    }

    [void] ImportOperatingSystem($OperatingSystem)
    {
        Import-MicrosoftDeploymentToolkitModule
        New-PSDrive -Name $this.PSDriveName -PSProvider "MDTProvider" -Root $this.PSDrivePath -Verbose:$false

        Try {
            $ErrorActionPreference = "Stop"
            Import-MDTOperatingSystem -Path $this.Path -SourcePath $OperatingSystem -DestinationFolder $this.Name -Verbose
            $ErrorActionPreference = "Continue"
        }
        Catch [Microsoft.Management.Infrastructure.CimException] {
            If ($_.FullyQualifiedErrorId -notlike "*ItemAlreadyExists*") {
                throw $_
            }
        }
        Finally {
        }
    }
}

[DscResource()]
class cMDTBuildPackage
{
    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Key)]
    [string]$Path

    [DscProperty(Mandatory)]
    [string]$PackageSourcePath
    
    [DscProperty(Mandatory)]
    [string]$PSDriveName

    [DscProperty(Mandatory)]
    [string]$PSDrivePath

    [void] Set()
    {
        if ($this.ensure -eq [Ensure]::Present) {
            $present = Invoke-TestPath -Path "$($this.path)\$($this.name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath
            if ( !$present ) {
                $this.ImportPackage()
            }
        }
        else {   
            Invoke-RemovePath -Path "$($this.path)\$($this.name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath -Verbose
        }
    }

    [bool] Test()
    {
        $present = Invoke-TestPath -Path "$($this.path)\$($this.name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath 

        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [cMDTBuildPackage] Get()
    {
        return $this
    }

    [void] ImportPackage()
    {
        # The Import-MDTPackage command crashes WMI when run from inside DSC. Using workflow is a work around.
        workflow Import-Pkg {
            [CmdletBinding()]
            param(
                [string]$PSDriveName,
                [string]$PSDrivePath,
                [string]$Path,
                [string]$Source
            )
            InlineScript {
                Import-MicrosoftDeploymentToolkitModule
                New-PSDrive -Name $Using:PSDriveName -PSProvider "MDTProvider" -Root $Using:PSDrivePath -Verbose:$false
                Import-MDTPackage -Path $Using:Path -SourcePath $Using:Source -Verbose
            }
        }
        Import-Pkg $this.PSDriveName $this.PSDrivePath $this.Path $this.PackageSourcePath
    }
}

[DscResource()]
class cMDTBuildPersistentDrive
{
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty(Key)]
    [string]$Path

    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Mandatory)]
    [string]$Description

    [DscProperty(Mandatory)]
    [string]$NetworkPath

    [void] Set()
    {
        if ($this.ensure -eq [Ensure]::Present) {
            $this.CreateDirectory()
        }
        else {
            $this.RemoveDirectory()
        }
    }

    [bool] Test()
    {
        $present = $this.TestDirectoryPath()
        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [cMDTBuildPersistentDrive] Get()
    {
        return $this
    }

    [bool] TestDirectoryPath()
    {
        $present = $false
        Import-MicrosoftDeploymentToolkitModule
        if (Test-Path -Path $this.Path -PathType Container -ErrorAction Ignore) {
            $mdtShares = (GET-MDTPersistentDrive -ErrorAction SilentlyContinue)
            If ($mdtShares) {
                ForEach ($share in $mdtShares) {
                    If ($share.Name -eq $this.Name) {
                        $present = $true
                    }
                }
            }
        }
        return $present
    }

    [void] CreateDirectory()
    {
        Import-MicrosoftDeploymentToolkitModule
        New-PSDrive -Name $this.Name -PSProvider "MDTProvider" -Root $this.Path -Description $this.Description -NetworkPath $this.NetworkPath -Verbose:$false | `
        Add-MDTPersistentDrive -Verbose
    }

    [void] RemoveDirectory()
    {
        Import-MicrosoftDeploymentToolkitModule
        Write-Verbose -Message "Removing MDTPersistentDrive $($this.Name)"
        New-PSDrive -Name $this.Name -PSProvider "MDTProvider" -Root $this.Path -Description $this.Description -NetworkPath $this.NetworkPath -Verbose:$false | `
        Remove-MDTPersistentDrive -Verbose
    }
}

[DscResource()]
class cMDTBuildPreReqs
{
    [DscProperty(Mandatory)]
    [Ensure]$Ensure
    
    [DscProperty(Key)]
    [string]$DownloadPath

    [void] Set()
    {
        Write-Verbose "Starting Set MDT PreReqs..."
        $DownloadFiles = Invoke-Expression (Get-Content -Path "$($PSScriptRoot)\cMDTBuildLabPrereqs.ps1" -Raw)

        if ($this.ensure -eq [Ensure]::Present) {
            $present = $this.TestDownloadPath()
            if ($present) {
                Write-Verbose "   Download folder present!"
            }
            else {
                New-Item -Path $this.DownloadPath -ItemType Directory -Force
            }

            #Set all files:               
            ForEach ($file in $downloadFiles) {
                if (Test-Path -Path "$($this.DownloadPath)\$($file.Folder)\$($file.File)") {
                    Write-Verbose "   $($file.Name) already present!"
                }
                else {
                    Write-Verbose "   Creating $($file.Name) folder..."
                    New-Item -Path "$($this.DownloadPath)\$($file.Folder)" -ItemType Directory -Force
                    if ($file.URI -like "*/*") {
                        $this.WebClientDownload($file.URI, "$($this.DownloadPath)\$($file.Folder)\$($file.File)")
                    }
                    else {
                        $this.CopyFromSource("$($PSScriptRoot)\$($file.URI)", "$($this.DownloadPath)\$($file.Folder)\$($file.File)")
                    }

                    # Workaround for external source script(s) from GitHub - change EOL
                    if ($file.Name -eq "CleanupBeforeSysprep") {
                        $script = Get-Content -Path "$($this.DownloadPath)\$($file.Folder)\$($file.File)"
                        if ($script -notlike '*`r`n*') {
                            $script.Replace('`n','`r`n')
                            Set-Content -Path "$($this.DownloadPath)\$($file.Folder)\$($file.File)" -Value $script
                        }
                    }
                    # Unpack ZIP sources
                    if ($file.Name -eq "APPV51") {
                        Invoke-ExpandArchive -Source "$($this.DownloadPath)\$($file.Folder)\$($file.File)" -Target "$($this.DownloadPath)\$($file.Folder)"
                    }
                }
            }
        }
        else {
            $this.RemoveDirectory("")
        }
        Write-Verbose "MDT PreReqs set completed!"
    }

    [bool] Test()
    {
        Write-Verbose "Testing MDT PreReqs..."
        $present = $this.TestDownloadPath()
        $DownloadFiles = Invoke-Expression (Get-Content -Path "$($PSScriptRoot)\cMDTBuildLabPrereqs.ps1" -Raw)

        if ($this.ensure -eq [Ensure]::Present) {            
            Write-Verbose "   Testing for download path.."            
            if($present) {
                Write-Verbose "   Download path found!"
            }            
            Else {
                Write-Verbose "   Download path not found!"
                return $false
            }

            ForEach ($File in $downloadFiles) {
                 Write-Verbose "   Testing for $($File.Name)..."
                 $present = (Test-Path -Path "$($this.DownloadPath)\$($File.Folder)\$($File.File)")
                 Write-Verbose "   $present"
                 if(!$Present) {return $false}
            }
        }
        else {
            if ($Present) {$present = $false}
            else {$present = $true}
        }

        Write-Verbose "Test completed!"
        return $present
    }

    [cMDTBuildPreReqs] Get()
    {
        return $this
    }

    [bool] TestDownloadPath()
    {
        $present = $false
        if (Test-Path -Path $this.DownloadPath -ErrorAction Ignore) {
            $present = $true
        }        
        return $present
    }

    [void] WebClientDownload($Source,$Target)
    {
        $WebClient = New-Object System.Net.WebClient
        Write-Verbose "      Downloading file $($Source)"
        Write-Verbose "      Downloading to $($Target)"
        $WebClient.DownloadFile($Source, $Target)
    }

    [void] CopyFromSource($Source,$Target)
    {
        Write-Verbose "      Copying $($Target)"
        Copy-Item -Path $Source -Destination $Target
    }

    [void] RemoveDirectory($referencefile = "")
    {
        Remove-Item -Path $this.DownloadPath -Force -Verbose     
    }
}

[DscResource()]
class cMDTBuildSelectionProfile
{
    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [DscProperty(Key)]
    [string]$Name

    [DscProperty()]
    [string]$Comments

    [DscProperty(Mandatory)]
    [string]$IncludePath

    [DscProperty(Mandatory)]
    [string]$PSDriveName

    [DscProperty(Mandatory)]
    [string]$PSDrivePath

    [void] Set()
    {
        if ($this.ensure -eq [Ensure]::Present) {
            $this.ImportSelectionProfile()
        }
        else {
            Invoke-RemovePath -Path "$($this.PSDriveName):\Selection Profiles\$($this.name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath -Verbose
        }
    }

    [bool] Test()
    {
        $present = Invoke-TestPath -Path "$($this.PSDriveName):\Selection Profiles\$($this.name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath
        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [cMDTBuildSelectionProfile] Get()
    {
        return $this
    }

    [void] ImportSelectionProfile()
    {
        Import-MicrosoftDeploymentToolkitModule
        New-PSDrive -Name $this.PSDriveName -PSProvider "MDTProvider" -Root $this.PSDrivePath -Verbose:$false
        New-Item -Path "$($this.PSDriveName):\Selection Profiles" -enable "True" -Name $this.Name -Comments $this.Comments -Definition "<SelectionProfile><Include path=`"$($this.IncludePath)`" /></SelectionProfile>" -ReadOnly "False" -Verbose
    }
}

[DscResource()]
class cMDTBuildTaskSequence
{

    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Key)]
    [string]$Path

    [DscProperty(Mandatory)]
    [string]$OSName

    [DscProperty(Mandatory)]
    [string]$Template

    [DscProperty(Mandatory)]
    [string]$ID

    [DscProperty(Mandatory)]
    [string]$OrgName

    [DscProperty(Mandatory)]
    [string]$PSDriveName

    [DscProperty(Mandatory)]
    [string]$PSDrivePath

    [void] Set()
    {
        if ($this.ensure -eq [Ensure]::Present) {
            $this.ImportTaskSequence()
        }
        else {
            Invoke-RemovePath -Path "$($this.path)\$($this.name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath -Verbose
        }
    }

    [bool] Test()
    {
        $present = Invoke-TestPath -Path "$($this.path)\$($this.name)" -PSDriveName $this.PSDriveName -PSDrivePath $this.PSDrivePath 
        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [cMDTBuildTaskSequence] Get()
    {
        return $this
    }

    [void] ImportTaskSequence()
    {
        Import-MicrosoftDeploymentToolkitModule
        New-PSDrive -Name $this.PSDriveName -PSProvider "MDTProvider" -Root $this.PSDrivePath -Verbose:$false
        Import-MDTTaskSequence -path $this.Path -Name $this.Name -Template $this.Template -Comments "Build Reference Image" -ID $this.ID -Version "1.0" -OperatingSystemPath $this.OSName -FullName "Windows User" -OrgName $this.OrgName -HomePage "about:blank" -Verbose
        # Disable Windows autoupdate
        $UnattendXML = "$($this.PSDrivePath)\control\$($this.ID)\Unattend.xml"
        $unattend = Get-Content -Path $UnattendXML
        $unattend = $unattend.Replace('<ProtectYourPC>1','<ProtectYourPC>3')
        Set-Content -Path $UnattendXML -Value $unattend
    }
}

[DscResource()]
class cMDTBuildTaskSequenceCustomize
{
    # Task Sequence File
    [DscProperty(Key)]
    [string]$TSFile

    # Step name
    [DscProperty(Key)]
    [string]$Name

    # New step name
    [DscProperty()]
    [string]$NewName

    # Step type
    [DscProperty(Mandatory)]
    [string]$Type

    # Group for step
    [DscProperty(Mandatory)]
    [string]$GroupName

    # SubGroup for step
    [DscProperty()]
    [string]$SubGroup

    # Enable/Disable step
    [DscProperty()]
    [string]$Disable

    # Description
    [DscProperty()]
    [string]$Description

    # Add this step after that step
    [DscProperty()]
    [string]$AddAfter

    # TS variable name
    [DscProperty()]
    [string]$TSVarName

    # TS variable value
    [DscProperty()]
    [string]$TSVarValue

    # OS name for OS features
    [DscProperty()]
    [string]$OSName

    # OS features
    [DscProperty()]
    [string]$OSFeatures

    # Command line for 'Run Command line' step
    [DscProperty()]
    [string]$Command

    # Start directory for 'Run Command line' step
    [DscProperty()]
    [string]$StartIn

    # Selection profile for 'Apply Patches' step
    [DscProperty()]
    [string]$SelectionProfile

    [DscProperty(Mandatory)]
    [string]$PSDriveName

    [DscProperty(Mandatory)]
    [string]$PSDrivePath

    [void] Set()
    {
        $TS = $this.LoadTaskSequence()
                
        # Set node:
        # $group     - 1st level
        # $AddGroup  - Group to add
        # $Step      - Step (or Group) to add
        # $AfterStep - Insert after this step (may be null)
        $group = $TS.sequence.group | ?{$_.Name -eq $this.GroupName}
        if ($this.Type -eq "Group") {
            $step = $group.group | ?{$_.Name -eq $this.Name}
        }
        else {
            $step = $group.step | ?{$_.Name -eq $this.Name}
        }

        if ($this.SubGroup) {
            $AddGroup = $group.group | ?{$_.name -eq $this.SubGroup}
            $AfterStep = $addGroup.step | ?{$_.Name -eq $this.AddAfter}
        }
        else {
            $addGroup = $group
            $AfterStep = $group.step | ?{$_.Name -eq $this.AddAfter}
        }

        if ($step) {
            # Change existing step or group
            if ($this.Disable -ne "") {
                $step.disable = $this.Disable
            }
            if ($this.NewName -ne "") {
                $step.Name = $this.NewName
            }
            if ($this.SelectionProfile -ne "") {
                $step.defaultVarList.variable.'#text' = $this.SelectionProfile
            }
        }
        else {
            # Create new step or group
            if ($this.Type -eq "Group") {
                $newStep = $TS.CreateElement("group")
                $newStep.SetAttribute("expand", "true")
            }
            else {
                $newStep = $TS.CreateElement("step")
            }

            # Set common attributes
            $newStep.SetAttribute("name", $this.Name)
            if ($this.Disable -ne "") {
                $newStep.SetAttribute("disable", $this.Disable)
            }
            else {
                $newStep.SetAttribute("disable", "false")
            }
            $newStep.SetAttribute("continueOnError", "false")
            if ($this.Description -ne "") {
                $newStep.SetAttribute("description", $this.Description)
            }
            else {
                $newStep.SetAttribute("description", "")
            }

            # Create new step
            switch ($this.Type) {
                "Set Task Sequence Variable" {
                    $this.SetTaskSequenceVariable($TS, $newStep)
                }
                "Install Roles and Features" {
                    $this.InstallRolesAndFeatures($TS, $newStep)
                }
                "Install Application" {
                    $this.AddApplication($TS, $newStep)
                }
                "Run Command Line" {
                    $this.RunCommandLine($TS, $newStep)
                }
                "Restart Computer" {
                    $this.RestartComputer($TS, $newStep)
                }
            }

            # Insert new step into TS
            if ($AfterStep) {
                $AddGroup.InsertAfter($newStep, $AfterStep) | Out-Null
            }
            else {
                $AddGroup.AppendChild($newStep) | Out-Null
            }
        }

        $TS.Save($this.TSFile)
    }

    [bool] Test()
    {
        $TS = $this.LoadTaskSequence()
        $present = $false

        $group = $TS.sequence.group | ?{$_.Name -eq $this.GroupName}
        if ($this.Type -eq "Group") {
            $step = $group.group | ?{$_.Name -eq $this.Name}
        }
        else {
            $step = $group.step | ?{$_.Name -eq $this.Name}
        }

        if (!$this.AddAfter) {
            if ($step) {
                if ($this.Disable -ne "") {
                    $present = ($step.disable -eq $this.Disable)
                }
                if ($this.SelectionProfile -ne "") {
                    $present = ($step.defaultVarList.variable.'#text' -eq $this.SelectionProfile)
                }
            }
            else {
                if ($this.NewName -ne "") {
                    # For rename "Custom Tasks" group only
                    $present = ( ($group.group | ?{$_.Name -eq $this.NewName}) )
                }
                elseif ($this.SubGroup) {
                    $addGroup = $group.group | ?{$_.name -eq $this.SubGroup}
                    $present = ( ($addGroup.step | ?{$_.Name -eq $this.Name}) )
                }
            }
        }
        else {
            if ($this.Type -eq "Group") {
                $present = ( ($group.group | ?{$_.Name -eq $this.Name}) )
            }
            else {
                $AddGroup = $group
                if ($this.SubGroup) {
                    $AddGroup = $group.group | ?{$_.name -eq $this.SubGroup}
                }
                $present = ( ($addGroup.step | ?{$_.Name -eq $this.Name}) )
            }
        }

        return $present
    }

    [cMDTBuildTaskSequenceCustomize] Get()
    {
        return $this
    }

    [xml] LoadTaskSequence()
    {
        $tsPath = $this.TSFile
        $xml = [xml](Get-Content $tsPath)
        return $xml
    }

    [void] SetTaskSequenceVariable($TS, $Step)
    {
        $Step.SetAttribute("type", "SMS_TaskSequence_SetVariableAction")
        $Step.SetAttribute("successCodeList", "0 3010")

        $varList = $TS.CreateElement("defaultVarList")
        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "VariableName")
        $varName.SetAttribute("property", "VariableName")
        $varName.AppendChild($TS.CreateTextNode($this.TSVarName)) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "VariableValue")
        $varName.SetAttribute("property", "VariableValue")
        $varName.AppendChild($TS.CreateTextNode($this.TSVarValue)) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $action = $TS.CreateElement("action")
        $action.AppendChild($TS.CreateTextNode('cscript.exe "%SCRIPTROOT%\ZTISetVariable.wsf"')) | Out-Null

        $Step.AppendChild($varList) | Out-Null
        $Step.AppendChild($action) | Out-Null
    }

    [void] InstallRolesAndFeatures($TS, $Step)
    {
        $OSIndex = @{
            "Windows 7"       = 4
            "Windows 8.1"     = 10
            "Windows 2012 R2" = 11
            "Windows 10"      = 13
            "Windows 2016"    = 14
        }

        $Step.SetAttribute("successCodeList", "0 3010")
        $Step.SetAttribute("type", "BDD_InstallRoles")
        $Step.SetAttribute("runIn", "WinPEandFullOS")
                                                
        $varList = $TS.CreateElement("defaultVarList")
        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "OSRoleIndex")
        $varName.SetAttribute("property", "OSRoleIndex")
        $varName.AppendChild($TS.CreateTextNode($OSIndex.$($this.OSName))) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "OSRoles")
        $varName.SetAttribute("property", "OSRoles")
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "OSRoleServices")
        $varName.SetAttribute("property", "OSRoleServices")
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "OSFeatures")
        $varName.SetAttribute("property", "OSFeatures")
        $varName.AppendChild($TS.CreateTextNode($this.OSFeatures)) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $action = $TS.CreateElement("action")
        $action.AppendChild($TS.CreateTextNode('cscript.exe "%SCRIPTROOT%\ZTIOSRole.wsf"')) | Out-Null

        $Step.AppendChild($varList) | Out-Null
        $Step.AppendChild($action) | Out-Null
    }

    [void] AddApplication($TS, $Step)
    {
        $Step.SetAttribute("successCodeList", "0 3010")
        $Step.SetAttribute("type", "BDD_InstallApplication")
        $Step.SetAttribute("runIn", "WinPEandFullOS")
                                        
        $varList = $TS.CreateElement("defaultVarList")
        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "ApplicationGUID")
        $varName.SetAttribute("property", "ApplicationGUID")

        # Get Application GUID
        Import-MicrosoftDeploymentToolkitModule
        New-PSDrive -Name $this.PSDriveName -PSProvider "MDTProvider" -Root $this.PSDrivePath -Verbose:$false | Out-Null
        $App = Get-ChildItem -Path "$($this.PSDriveName):\Applications" -Recurse | ?{ $_.Name -eq  $this.Name }

        $varName.AppendChild($TS.CreateTextNode($($App.guid))) | Out-Null
        $varList.AppendChild($varName) | Out-Null
                                                
        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "ApplicationSuccessCodes")
        $varName.SetAttribute("property", "ApplicationSuccessCodes")
        $varName.AppendChild($TS.CreateTextNode("0 3010")) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $action = $TS.CreateElement("action")
        $action.AppendChild($TS.CreateTextNode('cscript.exe "%SCRIPTROOT%\ZTIApplications.wsf"')) | Out-Null

        $Step.AppendChild($varList) | Out-Null
        $Step.AppendChild($action) | Out-Null
    }

    [void] RunCommandLine($TS, $Step)
    {
        $Step.SetAttribute("startIn", $this.StartIn)
        $Step.SetAttribute("successCodeList", "0 3010")
        $Step.SetAttribute("type", "SMS_TaskSequence_RunCommandLineAction")
        $Step.SetAttribute("runIn", "WinPEandFullOS")

        $varList = $TS.CreateElement("defaultVarList")
        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "PackageID")
        $varName.SetAttribute("property", "PackageID")
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "RunAsUser")
        $varName.SetAttribute("property", "RunAsUser")
        $varName.AppendChild($TS.CreateTextNode("false")) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "SMSTSRunCommandLineUserName")
        $varName.SetAttribute("property", "SMSTSRunCommandLineUserName")
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "SMSTSRunCommandLineUserPassword")
        $varName.SetAttribute("property", "SMSTSRunCommandLineUserPassword")
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "LoadProfile")
        $varName.SetAttribute("property", "LoadProfile")
        $varName.AppendChild($TS.CreateTextNode("false")) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $action = $TS.CreateElement("action")
        $action.AppendChild($TS.CreateTextNode($this.Command)) | Out-Null

        $Step.AppendChild($varList) | Out-Null
        $Step.AppendChild($action) | Out-Null
    }

    [void] RestartComputer($TS, $Step)
    {
        $Step.SetAttribute("successCodeList", "0 3010")
        $Step.SetAttribute("type", "SMS_TaskSequence_RebootAction")
        $Step.SetAttribute("runIn", "WinPEandFullOS")

        $varList = $TS.CreateElement("defaultVarList")
        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "Message")
        $varName.SetAttribute("property", "Message")
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "MessageTimeout")
        $varName.SetAttribute("property", "MessageTimeout")
        $varName.AppendChild($TS.CreateTextNode("60")) | Out-Null
        $varList.AppendChild($varName) | Out-Null

        $varName = $TS.CreateElement("variable")
        $varName.SetAttribute("name", "Target")
        $varName.SetAttribute("property", "Target")
        $varList.AppendChild($varName) | Out-Null

        $action = $TS.CreateElement("action")
        $action.AppendChild($TS.CreateTextNode("smsboot.exe /target:WinPE")) | Out-Null

        $Step.AppendChild($varList) | Out-Null
        $Step.AppendChild($action) | Out-Null
    }
}

[DscResource()]
class cMDTBuildUpdateBootImage
{
    [DscProperty(Key)]
    [string]$Version

    [DscProperty(Key)]
    [string]$PSDeploymentShare

    [DscProperty(Mandatory)]
    [string]$PSDrivePath

    [DscProperty()]
    [string]$ExtraDirectory

    [DscProperty()]
    [string]$BackgroundFile

    [DscProperty()]
    [string]$LiteTouchWIMDescription
      
    [void] Set()
    {
        $this.UpdateBootImage()
    }

    [bool] Test()
    {
        Return ($this.VerifyVersion())
    }

    [cMDTBuildUpdateBootImage] Get()
    {
        return $this
    }

    [bool] VerifyVersion()
    {
        [bool]$match = $false

        if ((Get-Content -Path "$($this.PSDrivePath)\Boot\CurrentBootImage.version" -ErrorAction Ignore) -eq $this.Version) {
            $match = $true
        }
        return $match
    }

    [void] UpdateBootImage()
    {
        Import-MicrosoftDeploymentToolkitModule
        New-PSDrive -Name $this.PSDeploymentShare -PSProvider "MDTProvider" -Root $this.PSDrivePath -Verbose:$false

        If ([string]::IsNullOrEmpty($($this.ExtraDirectory))) {
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.ExtraDirectory -Value ""
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.ExtraDirectory -Value ""
        }
        ElseIf (Invoke-TestPath -Path "$($this.PSDrivePath)\$($this.ExtraDirectory)") {
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.ExtraDirectory -Value "$($this.PSDrivePath)\$($this.ExtraDirectory)"                        
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.ExtraDirectory -Value "$($this.PSDrivePath)\$($this.ExtraDirectory)"                       
        }

        If ([string]::IsNullOrEmpty($($this.BackgroundFile))) {
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.BackgroundFile -Value ""
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.BackgroundFile -Value ""
        }
        ElseIf (Invoke-TestPath -Path "$($this.PSDrivePath)\$($this.BackgroundFile)") {
             Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.BackgroundFile -Value "$($this.PSDrivePath)\$($this.BackgroundFile)"
             Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.BackgroundFile -Value "$($this.PSDrivePath)\$($this.BackgroundFile)"
        }
        Else {
             Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.BackgroundFile -Value $this.BackgroundFile
             Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.BackgroundFile -Value $this.BackgroundFile
        }

        If ($this.LiteTouchWIMDescription) {
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.LiteTouchWIMDescription -Value "$($this.LiteTouchWIMDescription) x64 $($this.Version)"
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.LiteTouchWIMDescription -Value "$($this.LiteTouchWIMDescription) x86 $($this.Version)"
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.LiteTouchISOName -Value "$($this.LiteTouchWIMDescription)_x64.iso".Replace(' ','_')
            Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.LiteTouchISOName -Value "$($this.LiteTouchWIMDescription)_x86.iso".Replace(' ','_')
        }

        Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.SelectionProfile -Value "Nothing"
        Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.SelectionProfile -Value "Nothing"

        # for offline remove Windows default apps
        Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.FeaturePacks -Value "winpe-dismcmdlets,winpe-mdac,winpe-netfx,winpe-powershell,winpe-storagewmi"

        Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x64.GenerateLiteTouchISO -Value $false
        Set-ItemProperty "$($this.PSDeploymentShare):" -Name Boot.x86.GenerateLiteTouchISO -Value $true

        #The Update-MDTDeploymentShare command crashes WMI when run from inside DSC. This section is a work around.
        workflow Update-DeploymentShare {
            #[Cmdletbinding()]
            param (
                [string]$PSDeploymentShare,
                [string]$PSDrivePath
            )
            InlineScript {
                Import-MicrosoftDeploymentToolkitModule
                New-PSDrive -Name $Using:PSDeploymentShare -PSProvider "MDTProvider" -Root $Using:PSDrivePath -Verbose:$false
                Update-MDTDeploymentShare -Path "$($Using:PSDeploymentShare):" -Force:$true -Compress:$true
            }
        }
        Update-DeploymentShare $this.PSDeploymentShare $this.PSDrivePath
        Set-Content -Path "$($this.PSDrivePath)\Boot\CurrentBootImage.version" -Value "$($this.Version)"
    }
}

Function Import-MicrosoftDeploymentToolkitModule
{
    If ( -Not (Get-Module MicrosoftDeploymentToolkit) ) {
        Import-Module "$env:ProgramFiles\Microsoft Deployment Toolkit\Bin\MicrosoftDeploymentToolkit.psd1" -ErrorAction Stop -Global -Verbose:$False
    }
}

Function Invoke-ExpandArchive
{
    [cmdletbinding(SupportsShouldProcess=$True,ConfirmImpact="Low")]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [string]$Source,
        [Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [string]$Target
    )

    [bool]$Verbosity
    If ($PSBoundParameters.Verbose) { $Verbosity = $True }
    Else { $Verbosity = $False }

    Write-Verbose "Expanding archive $($Source) to $($Target)"
    Expand-Archive $Source -DestinationPath $Target -Force -Verbose:$Verbosity
}

Function Invoke-RemovePath
{
    [cmdletbinding(SupportsShouldProcess=$True,ConfirmImpact="Low")]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [string]$Path,
        [Parameter()]
        [string]$PSDriveName,
        [Parameter()]
        [string]$PSDrivePath
    )

    [bool]$Verbosity
    If ($PSBoundParameters.Verbose) { $Verbosity = $True }
    Else { $Verbosity = $False }

    if (($PSDrivePath) -and ($PSDriveName)) {
        Import-MicrosoftDeploymentToolkitModule
        New-PSDrive -Name $PSDriveName -PSProvider "MDTProvider" -Root $PSDrivePath -Verbose:$False | `
        Remove-Item -Path "$($Path)" -Force -Verbose:$Verbosity
    }
    else {
        Remove-Item -Path "$($Path)" -Force -Verbose:$Verbosity
    }
}

Function Invoke-TestPath
{
    [cmdletbinding(SupportsShouldProcess=$True,ConfirmImpact="Low")]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [string]$Path,
        [Parameter()]
        [string]$PSDriveName,
        [Parameter()]
        [string]$PSDrivePath
    )

    [bool]$present = $false

    if (($PSDrivePath) -and ($PSDriveName)) {
        Import-MicrosoftDeploymentToolkitModule
        if (New-PSDrive -Name $PSDriveName -PSProvider "MDTProvider" -Root $PSDrivePath -Verbose:$false | `
            Test-Path -Path "$($Path)" -ErrorAction Ignore) {
            $present = $true
        }        
    }
    else {
        if (Test-Path -Path "$($Path)" -ErrorAction Ignore) {
            $present = $true
        }
    }
    return $present
}
