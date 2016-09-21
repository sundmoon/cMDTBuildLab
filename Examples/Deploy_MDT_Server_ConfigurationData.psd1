﻿@{
    AllNodes = 
    @(
        @{

            #Global Settings for the configuration of Desired State Local Configuration Manager:
            NodeName                    = "*"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            RebootNodeIfNeeded          = $true
            ConfigurationMode           = "ApplyAndAutoCorrect"      
        },

        @{

            #Node Settings for the configuration of an MDT Server:
            NodeName           = "$env:computername"
            Role               = "MDT Server"

            #Sources for download/Prereqs
            SourcePath         = "E:\Source"

            #Local account to create for MDT
            MDTLocalAccount    = "SVCMDTConnect001"
            MDTLocalPassword   = "P@ssw0rd"

            #MDT deoployment share paths
            PSDriveName        = "MDT001"
            PSDrivePath        = "E:\MDTBuildLab"
            PSDriveShareName   = "MDTBuildLab$"

            #Operating system MDT directory information
            OSDirectories   = @(
                @{  
                    Ensure = "Present"
                    OperatingSystem = "Windows 7"
                }
                @{  
                    Ensure = "Present"
                    OperatingSystem = "Windows 8.1"
                }
                @{  
                    Ensure = "Present"
                    OperatingSystem = "Windows 10"
                }
                @{  
                    Ensure = "Present"
                    OperatingSystem = "Windows 2012 R2"
                }
                @{  
                    Ensure = "Present"
                    OperatingSystem = "Windows 2016 TP5"
                }
            )

            #MDT Application Folder Structure
            ApplicationFolderStructure = @(
                @{  
                    Ensure     = "Present"
                    Folder     = "Core"
                    SubFolders = @(
                        @{  
                            Ensure    = "Present"
                            SubFolder = "Configure"
                        }
                        @{  
                            Ensure    = "Present"
                            SubFolder = "Microsoft"
                        }
                    )
                }
                @{  
                    Ensure = "Present"
                    Folder = "Common Applications"
                }
            )

			PackagesFolderStructure = @(
				@{
					Ensure = "Present"
					Folder = "Windows 7 x86"
				}
				@{
					Ensure = "Present"
					Folder = "Windows 7 x64"
				}
				@{
					Ensure = "Present"
					Folder = "Windows 10 x86"
				}
				@{
					Ensure = "Present"
					Folder = "Windows 10 x64"
				}
			)

            #Operating systems to import to MDT
            OperatingSystems   = @(
                @{
                    Ensure     = "Present"
                    Name       = "Windows 7 x86"
                    Path       = "Windows 7"
                    SourcePath = "$SourcePath\Windows7x86"
                }
                @{
                    Ensure     = "Present"
                    Name       = "Windows 7 x64"
                    Path       = "Windows 7"
                    SourcePath = "$SourcePath\Windows7x64"
                }
                @{
                    Ensure     = "Present"
                    Name       = "Windows 8.1 x86"
                    Path       = "Windows 8.1"
                    SourcePath = "$SourcePath\Windows81x86"
                }
                @{
                    Ensure     = "Present"
                    Name       = "Windows 8.1 x64"
                    Path       = "Windows 8.1"
                    SourcePath = "$SourcePath\Windows81x64"
                }
                @{
                    Ensure     = "Present"
                    Name       = "Windows 10 x86"
                    Path       = "Windows 10"
                    SourcePath = "$SourcePath\Windows10x86"
                }
                @{
                    Ensure     = "Present"
                    Name       = "Windows 10 x64"
                    Path       = "Windows 10"
                    SourcePath = "$SourcePath\Windows10x64"
                }
                @{
                    Ensure     = "Present"
                    Name       = "Windows 2012 R2"
                    Path       = "Windows 2012 R2"
                    SourcePath = "$SourcePath\Windows2012R2"
                }
                @{
                    Ensure     = "Present"
                    Name       = "Windows 2016 TP5"
                    Path       = "Windows 2016 TP5"
                    SourcePath = "$SourcePath\Windows2016TP5"
                }
            )

            #Applications to import
            Applications   = @(
				@{
                    Ensure                = "Present"
                    Name                  = "Install - Microsoft Visual C++"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "cscript.exe Install-MicrosoftVisualC++x86x64.wsf"
                    ApplicationSourcePath = "VC++"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Install - Microsoft Silverlight - x86"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "Silverlight.exe /Q"
                    ApplicationSourcePath = "Silverlight_x86"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Install - Microsoft Silverlight - x64"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "Silverlight_x64.exe /Q"
                    ApplicationSourcePath = "Silverlight_x64"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Install - Windows Management Framework 3.0 - x86"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe Windows6.1-KB2506143-x86.msu /quiet /norestart"
                    ApplicationSourcePath = "WMF30x86"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Install - Windows Management Framework 3.0 - x64"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe Windows6.1-KB2506143-x64.msu /quiet /norestart"
                    ApplicationSourcePath = "WMF30x64"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Install - Windows Management Framework 5.0 - x64"
                    Path                  = "\Applications\Core\Microsoft"
                    CommandLine           = "wusa.exe Win8.1AndW2K12R2-KB3134758-x64.msu /quiet /norestart"
                    ApplicationSourcePath = "WMF50x64"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Configure - Set Control+Shift Keyboard Toggle"
                    Path                  = "\Applications\Core\Configure"
                    CommandLine           = "cmd /c reg import Toggle.reg"
                    ApplicationSourcePath = "KeyboardToggle"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Action - CleanupBeforeSysprep"
                    Path                  = "\Applications\Core\Configure"
                    CommandLine           = "cscript.exe Action-CleanupBeforeSysprep.wsf"
                    ApplicationSourcePath = "CleanupBeforeSysprep"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Configure - Remove Windows Default Applications"
                    Path                  = "\Applications\Core\Configure"
                    CommandLine           = "powershell.exe -ExecutionPolicy Bypass -File RemoveApps.ps1"
                    ApplicationSourcePath = "RemoveApps"
				}
				@{
                    Ensure                = "Present"
                    Name                  = "Configure - Set Start Layout"
                    Path                  = "\Applications\Core\Configure"
                    CommandLine           = "powershell.exe -ExecutionPolicy Bypass -File Customize-DefaultProfile.ps1"
                    ApplicationSourcePath = "Set-Startlayout"
				}
                @{
                    Ensure                = "Present"
                    Name                  = "Install - APP-V Client 5.1 - x86-x64"
                    Path                  = "\Applications\Common Applications"
                    CommandLine           = "appv_client_setup.exe /ACCEPTEULA /q /ENABLEPACKAGESCRIPTS=1"
                    ApplicationSourcePath = "APPV51x86x64"
                }
            )

			#Packages
			Packages = @(
				@{
					Ensure            = "Present"
					Name              = "Package_for_KB3020369 neutral x86 6.1.1.1"
					Path              = "\Packages\Windows 7 x86"
					PackageSourcePath = "Update for Windows 7 (KB3020369)"
				}
				@{
					Ensure            = "Present"
					Name              = "Package_for_KB3125574 neutral x86 6.1.4.4"
					Path              = "\Packages\Windows 7 x86"
					PackageSourcePath = "Update for Windows 7 (KB3125574)"
				}
				@{
					Ensure            = "Present"
					Name              = "Package_for_KB3020369 neutral amd64 6.1.1.1"
					Path              = "\Packages\Windows 7 x64"
					PackageSourcePath = "Update for Windows 7 for x64-based Systems (KB3020369)"
				}
				@{
					Ensure            = "Present"
					Name              = "Package_for_KB3125574 neutral amd64 6.1.4.4"
					Path              = "\Packages\Windows 7 x64"
					PackageSourcePath = "Update for Windows 7 for x64-based Systems (KB3125574)"
				}
				@{
					Ensure            = "Present"
					Name              = "Package_for_RollupFix neutral x86 14393.187.1.0"
					Path              = "\Packages\Windows 10 x86"
					PackageSourcePath = "Cumulative Update for Windows 10 Version 1607 (KB3193494)"
				}
				@{
					Ensure            = "Present"
					Name              = "Package_for_RollupFix neutral amd64 14393.187.1.0"
					Path              = "\Packages\Windows 10 x64"
					PackageSourcePath = "Cumulative Update for Windows 10 Version 1607 for x64-based Systems (KB3193494)"
				}
			)

            #Task sqeuences; are dependent on imported Operating system and Applications in MDT
            TaskSequences   = @(
                @{  
                    Ensure   = "Present"
                    Name     = "Windows 7 x86"
                    Path     = "Windows 7"
					OSName   = "Windows 7\Windows 7 ENTERPRISE in Windows 7 x86 install.wim"
                    OrgName  = "BuildLab"
					Template = "Client.xml"
                    ID       = "REFW7X86-001"
					Customize = @(
						@{
							Name       = "Windows Update (Pre-Application Installation)"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							Disable    = "false"
						}
						@{
							Name       = "Windows Update (Post-Application Installation)"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							Disable    = "false"
						}
						@{
							Name       = "Custom Tasks (Pre-Windows Update)"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Tattoo"
						}
						@{
							Name       = "Custom Tasks"
							Type       = "Group"
							GroupName  = "State Restore"
							NewName    = "Custom Tasks (Post-Windows Update)"
						}
						@{
							Name       = "Cleanup before Sysprep"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Apply Local GPO Package"
						}
						@{
							Name       = "Install - Microsoft NET Framework 3.5.1"
							Type       = "Install Roles and Features"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							OSName     = "Windows 7"
							OSFeatures = "InboxGames,NetFx3,TelnetClient"
						}
						@{
							Name       = "Install - Microsoft Visual C++"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Configure - Remove Windows Default Applications"
						}
						@{
							Name       = "Install - Microsoft Silverlight - x86"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft Visual C++"
						}
						@{
							Name       = "Configure - Set Control+Shift Keyboard Toggle"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft Silverlight - x86"
						}
						@{
							Name       = "Install APP-V 5.1"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Install Applications"
						}
						@{
							Name       = "Install - Windows Management Framework 3.0 - x86"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Install APP-V 5.1"
						}
						@{
							Name       = "Restart Computer 1"
							Type       = "Restart Computer"
							GroupName  = "State Restore"
							SubGroup   = "Install APP-V 5.1"
							AddAfter   = "Install - Windows Management Framework 3.0 - x86"
						}
						@{
							Name       = "Install - APP-V Client 5.1 - x86-x64"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Install APP-V 5.1"
							Disable    = "true"
							AddAfter   = "Restart Computer 1"
						}
						@{
							Name       = "Restart Computer 2"
							Type       = "Restart Computer"
							GroupName  = "State Restore"
							SubGroup   = "Install APP-V 5.1"
							Disable    = "true"
							AddAfter   = "Install - APP-V Client 5.1 - x86-x64"
						}
						@{
							Name       = "Suspend"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							Disable    = "true"
							Command    = 'cscript.exe "%SCRIPTROOT%\LTISuspend.wsf"'
							AddAfter   = "Opt In to CEIP and WER"
						}
						@{
							Name       = "Action - CleanupBeforeSysprep"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Cleanup before Sysprep"
						}
						@{
							Name       = "Restart Computer"
							Type       = "Restart Computer"
							GroupName  = "State Restore"
							SubGroup   = "Cleanup before Sysprep"
							AddAfter   = "Action - CleanupBeforeSysprep"
						}
					)
                }
                @{  
                    Ensure   = "Present"
                    Name     = "Windows 7 x64"
                    Path     = "Windows 7"
					OSName   = "Windows 7\Windows 7 ENTERPRISE in Windows 7 x64 install.wim"
                    OrgName  = "BuildLab"
					Template = "Client.xml"
                    ID       = "REFW7X64-001"
					Customize = @(
						@{
							Name       = "Windows Update (Pre-Application Installation)"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							Disable    = "false"
						}
						@{
							Name       = "Windows Update (Post-Application Installation)"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							Disable    = "false"
						}
						@{
							Name       = "Custom Tasks (Pre-Windows Update)"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Tattoo"
						}
						@{
							Name       = "Custom Tasks"
							Type       = "Group"
							GroupName  = "State Restore"
							NewName    = "Custom Tasks (Post-Windows Update)"
						}
						@{
							Name       = "Cleanup before Sysprep"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Apply Local GPO Package"
						}
						@{
							Name       = "Install - Microsoft NET Framework 3.5.1"
							Type       = "Install Roles and Features"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							OSName     = "Windows 7"
							OSFeatures = "InboxGames,NetFx3,TelnetClient"
						}
						@{
							Name       = "Install - Microsoft Visual C++"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Configure - Remove Windows Default Applications"
						}
						@{
							Name       = "Install - Microsoft Silverlight - x64"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft Visual C++"
						}
						@{
							Name       = "Configure - Set Control+Shift Keyboard Toggle"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft Silverlight - x64"
						}
						@{
							Name       = "Install APP-V 5.1"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Install Applications"
						}
						@{
							Name       = "Install - Windows Management Framework 3.0 - x64"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Install APP-V 5.1"
						}
						@{
							Name       = "Restart Computer 1"
							Type       = "Restart Computer"
							GroupName  = "State Restore"
							SubGroup   = "Install APP-V 5.1"
							AddAfter   = "Install - Windows Management Framework 3.0 - x64"
						}
						@{
							Name       = "Install - APP-V Client 5.1 - x86-x64"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Install APP-V 5.1"
							Disable    = "true"
							AddAfter   = "Restart Computer 1"
						}
						@{
							Name       = "Restart Computer 2"
							Type       = "Restart Computer"
							GroupName  = "State Restore"
							SubGroup   = "Install APP-V 5.1"
							Disable    = "true"
							AddAfter   = "Install - APP-V Client 5.1 - x86-x64"
						}
						@{
							Name       = "Suspend"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							Disable    = "true"
							Command    = 'cscript.exe "%SCRIPTROOT%\LTISuspend.wsf"'
							AddAfter   = "Opt In to CEIP and WER"
						}
						@{
							Name       = "Action - CleanupBeforeSysprep"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Cleanup before Sysprep"
						}
						@{
							Name       = "Restart Computer"
							Type       = "Restart Computer"
							GroupName  = "State Restore"
							SubGroup   = "Cleanup before Sysprep"
							AddAfter   = "Action - CleanupBeforeSysprep"
						}
					)
                }
                @{  
                    Ensure   = "Present"
                    Name     = "Windows 8.1 x86"
                    Path     = "Windows 8.1"
					OSName   = "Windows 8.1\Windows 8.1 Enterprise in Windows 8.1 x86 install.wim"
                    OrgName  = "BuildLab"
					Template = "Client.xml"
                    ID       = "REFW81X86-001"
					Customize = @(
						@{
							Name       = "Windows Update (Pre-Application Installation)"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							Disable    = "false"
						}
						@{
							Name       = "Custom Tasks (Pre-Windows Update)"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Tattoo"
						}
						@{
							Name       = "Custom Tasks"
							Type       = "Group"
							GroupName  = "State Restore"
							NewName    = "Custom Tasks (Post-Windows Update)"
						}
						@{
							Name       = "Cleanup before Sysprep"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Apply Local GPO Package"
						}
						@{
							Name       = "Install - Microsoft NET Framework 3.5.1"
							Type       = "Install Roles and Features"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							OSName     = "Windows 8.1"
							OSFeatures = "NetFx3,TelnetClient"
						}
						@{
							Name       = "Configure - Remove Windows Default Applications"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft NET Framework 3.5.1"
						}
						@{
							Name       = "Install - Microsoft Visual C++"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Configure - Remove Windows Default Applications"
						}
						@{
							Name       = "Install - Microsoft Silverlight - x86"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft Visual C++"
						}
						@{
							Name       = "Configure - Set Control+Shift Keyboard Toggle"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft Silverlight - x64"
						}
						@{
							Name       = "Configure - Set Start Layout"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Configure - Set Control+Shift Keyboard Toggle"
						}
						@{
							Name       = "Install APP-V 5.1"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Install Applications"
						}
						@{
							Name       = "Install - APP-V Client 5.1 - x86-x64"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Install APP-V 5.1"
							Disable    = "true"
						}
						@{
							Name       = "Restart Computer 1"
							Type       = "Restart Computer"
							GroupName  = "State Restore"
							SubGroup   = "Install APP-V 5.1"
							Disable    = "true"
							AddAfter   = "Install - APP-V Client 5.1 - x86-x64"
						}
						@{
							Name       = "Suspend"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							Disable    = "true"
							Command    = 'cscript.exe "%SCRIPTROOT%\LTISuspend.wsf"'
							AddAfter   = "Opt In to CEIP and WER"
						}
						@{
							Name       = "Action - CleanupBeforeSysprep"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Cleanup before Sysprep"
						}
						@{
							Name       = "Restart Computer"
							Type       = "Restart Computer"
							GroupName  = "State Restore"
							SubGroup   = "Cleanup before Sysprep"
							AddAfter   = "Action - CleanupBeforeSysprep"
						}
					)
                }
                @{  
                    Ensure   = "Present"
                    Name     = "Windows 8.1 x64"
                    Path     = "Windows 8.1"
					OSName   = "Windows 8.1\Windows 8.1 Enterprise in Windows 8.1 x64 install.wim"
                    OrgName  = "BuildLab"
					Template = "Client.xml"
                    ID       = "REFW81X64-001"
					Customize = @(
						@{
							Name       = "Windows Update (Pre-Application Installation)"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							Disable    = "false"
						}
						@{
							Name       = "Custom Tasks (Pre-Windows Update)"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Tattoo"
						}
						@{
							Name       = "Custom Tasks"
							Type       = "Group"
							GroupName  = "State Restore"
							NewName    = "Custom Tasks (Post-Windows Update)"
						}
						@{
							Name       = "Cleanup before Sysprep"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Apply Local GPO Package"
						}
						@{
							Name       = "Install - Microsoft NET Framework 3.5.1"
							Type       = "Install Roles and Features"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							OSName     = "Windows 8.1"
							OSFeatures = "NetFx3,TelnetClient"
						}
						@{
							Name       = "Configure - Remove Windows Default Applications"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft NET Framework 3.5.1"
						}
						@{
							Name       = "Install - Microsoft Visual C++"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Configure - Remove Windows Default Applications"
						}
						@{
							Name       = "Install - Microsoft Silverlight - x64"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft Visual C++"
						}
						@{
							Name       = "Configure - Set Control+Shift Keyboard Toggle"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft Silverlight - x64"
						}
						@{
							Name       = "Configure - Set Start Layout"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Configure - Set Control+Shift Keyboard Toggle"
						}
						@{
							Name       = "Install APP-V 5.1"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Install Applications"
						}
						@{
							Name       = "Install - APP-V Client 5.1 - x86-x64"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Install APP-V 5.1"
							Disable    = "true"
						}
						@{
							Name       = "Restart Computer 1"
							Type       = "Restart Computer"
							GroupName  = "State Restore"
							SubGroup   = "Install APP-V 5.1"
							Disable    = "true"
							AddAfter   = "Install - APP-V Client 5.1 - x86-x64"
						}
						@{
							Name       = "Suspend"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							Disable    = "true"
							Command    = 'cscript.exe "%SCRIPTROOT%\LTISuspend.wsf"'
							AddAfter   = "Opt In to CEIP and WER"
						}
						@{
							Name       = "Action - CleanupBeforeSysprep"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Cleanup before Sysprep"
						}
						@{
							Name       = "Restart Computer"
							Type       = "Restart Computer"
							GroupName  = "State Restore"
							SubGroup   = "Cleanup before Sysprep"
							AddAfter   = "Action - CleanupBeforeSysprep"
						}
					)
                }
                @{
                    Ensure   = "Present"
                    Name     = "Windows 10 x86"
                    Path     = "Windows 10"
					OSName   = "Windows 10\Windows 10 Enterprise in Windows 10 x86 install.wim"
                    OrgName  = "BuildLab"
					Template = "Client.xml"
                    ID       = "REFW10X86-001"
					Customize = @(
						@{
							Name       = "Windows Update (Pre-Application Installation)"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							Disable    = "false"
						}
						@{
							Name       = "Custom Tasks (Pre-Windows Update)"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Tattoo"
						}
						@{
							Name       = "Custom Tasks"
							Type       = "Group"
							GroupName  = "State Restore"
							NewName    = "Custom Tasks (Post-Windows Update)"
						}
						@{
							Name       = "Cleanup before Sysprep"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Apply Local GPO Package"
						}
						@{
							Name       = "Install - Microsoft NET Framework 3.5.1"
							Type       = "Install Roles and Features"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							OSName     = "Windows 10"
							OSFeatures = "NetFx3,TelnetClient"
						}
						@{
							Name       = "Configure - Remove Windows Default Applications"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft NET Framework 3.5.1"
						}
						@{
							Name       = "Install - Microsoft Visual C++"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Configure - Remove Windows Default Applications"
						}
						@{
							Name       = "Install - Microsoft Silverlight - x86"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft Visual C++"
						}
						@{
							Name       = "Configure - Set Control+Shift Keyboard Toggle"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft Silverlight - x86"
						}
						@{
							Name       = "Configure - Enable App-V Client"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Configure - Set Control+Shift Keyboard Toggle"
							Command    = 'powershell.exe -ExecutionPolicy ByPass -Command "Enable-Appv; Set-AppvClientConfiguration -EnablePackageScripts 1"'
						}
						@{
							Name       = "Suspend"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							Disable    = "true"
							Command    = 'cscript.exe "%SCRIPTROOT%\LTISuspend.wsf"'
							AddAfter   = "Opt In to CEIP and WER"
						}
						@{
							Name       = "Action - CleanupBeforeSysprep"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Cleanup before Sysprep"
						}
						@{
							Name       = "Restart Computer"
							Type       = "Restart Computer"
							GroupName  = "State Restore"
							SubGroup   = "Cleanup before Sysprep"
							AddAfter   = "Action - CleanupBeforeSysprep"
						}
					)
                }
                @{
                    Ensure   = "Present"
                    Name     = "Windows 10 x64"
                    Path     = "Windows 10"
					OSName   = "Windows 10\Windows 10 Enterprise in Windows 10 x64 install.wim"
                    OrgName  = "BuildLab"
					Template = "Client.xml"
                    ID       = "REFW10X64-001"
					Customize = @(
						@{
							Name       = "Windows Update (Pre-Application Installation)"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							Disable    = "false"
						}
						@{
							Name       = "Custom Tasks (Pre-Windows Update)"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Tattoo"
						}
						@{
							Name       = "Custom Tasks"
							Type       = "Group"
							GroupName  = "State Restore"
							NewName    = "Custom Tasks (Post-Windows Update)"
						}
						@{
							Name       = "Cleanup before Sysprep"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Apply Local GPO Package"
						}
						@{
							Name       = "Install - Microsoft NET Framework 3.5.1"
							Type       = "Install Roles and Features"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							OSName     = "Windows 10"
							OSFeatures = "NetFx3,TelnetClient"
						}
						@{
							Name       = "Configure - Remove Windows Default Applications"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft NET Framework 3.5.1"
						}
						@{
							Name       = "Install - Microsoft Visual C++"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Configure - Remove Windows Default Applications"
						}
						@{
							Name       = "Install - Microsoft Silverlight - x64"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft Visual C++"
						}
						@{
							Name       = "Configure - Set Control+Shift Keyboard Toggle"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft Silverlight - x64"
						}
						@{
							Name       = "Configure - Enable App-V Client"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Configure - Set Control+Shift Keyboard Toggle"
							Command    = 'powershell.exe -ExecutionPolicy ByPass -Command "Enable-Appv; Set-AppvClientConfiguration -EnablePackageScripts 1"'
						}
						@{
							Name       = "Suspend"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							Disable    = "true"
							Command    = 'cscript.exe "%SCRIPTROOT%\LTISuspend.wsf"'
							AddAfter   = "Opt In to CEIP and WER"
						}
						@{
							Name       = "Action - CleanupBeforeSysprep"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Cleanup before Sysprep"
						}
						@{
							Name       = "Restart Computer"
							Type       = "Restart Computer"
							GroupName  = "State Restore"
							SubGroup   = "Cleanup before Sysprep"
							AddAfter   = "Action - CleanupBeforeSysprep"
						}
					)
                }
                @{  
                    Ensure   = "Present"
                    Name     = "Windows 2012 R2"
                    Path     = "Windows 2012 R2"
					OSName   = "Windows 2012 R2\Windows Server 2012 R2 SERVERSTANDARD in Windows 2012 R2 install.wim"
                    OrgName  = "BuildLab"
					Template = "Server.xml"
                    ID       = "REFW2012R2-001"
					Customize = @(
						@{
							Name       = "Windows Update (Pre-Application Installation)"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							Disable    = "false"
						}
						@{
							Name       = "Custom Tasks (Pre-Windows Update)"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Tattoo"
						}
						@{
							Name       = "Custom Tasks"
							Type       = "Group"
							GroupName  = "State Restore"
							NewName    = "Custom Tasks (Post-Windows Update)"
						}
						@{
							Name       = "Install WMF 5.0"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Install Applications"
						}
						@{
							Name       = "Cleanup before Sysprep"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Apply Local GPO Package"
						}
						@{
							Name       = "Install - Microsoft NET Framework 3.5.1"
							Type       = "Install Roles and Features"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							OSName     = "Windows 2012 R2"
							OSFeatures = "NET-Framework-Features,Telnet-Client"
						}
						@{
							Name       = "Configure - Set Control+Shift Keyboard Toggle"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft NET Framework 3.5.1"
						}
						@{
							Name       = "Install - Windows Management Framework 5.0 - x64"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Install WMF 5.0"
						}
						@{
							Name       = "Restart Computer 1"
							Type       = "Restart Computer"
							GroupName  = "State Restore"
							SubGroup   = "Install WMF 5.0"
							AddAfter   = "Install - Windows Management Framework 5.0 - x64"
						}
						@{
							Name       = "Action - CleanupBeforeSysprep"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Cleanup before Sysprep"
						}
						@{
							Name       = "Restart Computer"
							Type       = "Restart Computer"
							GroupName  = "State Restore"
							SubGroup   = "Cleanup before Sysprep"
							AddAfter   = "Action - CleanupBeforeSysprep"
						}
					)
                }
                @{  
                    Ensure   = "Present"
                    Name     = "Windows 2016 TP5"
                    Path     = "Windows 2016 TP5"
					OSName   = "Windows 2016 TP5\Windows Server 2016 Technical Preview 5 SERVERDATACENTER in Windows 2016 TP5 install.wim"
                    OrgName  = "BuildLab"
					Template = "Server.xml"
                    ID       = "REFW2016TP5-001"
					Customize = @(
						@{
							Name       = "Windows Update (Pre-Application Installation)"
							Type       = "Run Command Line"
							GroupName  = "State Restore"
							Disable    = "false"
						}
						@{
							Name       = "Custom Tasks (Pre-Windows Update)"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Tattoo"
						}
						@{
							Name       = "Custom Tasks"
							Type       = "Group"
							GroupName  = "State Restore"
							NewName    = "Custom Tasks (Post-Windows Update)"
						}
						@{
							Name       = "Cleanup before Sysprep"
							Type       = "Group"
							GroupName  = "State Restore"
							AddAfter   = "Apply Local GPO Package"
						}
						<# Not released in MDT 2013 Update 2
						@{
							Name       = "Install - Microsoft NET Framework 3.5.1"
							Type       = "Install Roles and Features"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							OSName     = "Windows 2012 R2"
							OSFeatures = "NET-Framework-Features,Telnet-Client"
						}
						#>
						@{
							Name       = "Configure - Set Control+Shift Keyboard Toggle"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Custom Tasks (Pre-Windows Update)"
							AddAfter   = "Install - Microsoft NET Framework 3.5.1"
						}
						@{
							Name       = "Action - CleanupBeforeSysprep"
							Type       = "Install Application"
							GroupName  = "State Restore"
							SubGroup   = "Cleanup before Sysprep"
						}
						@{
							Name       = "Restart Computer"
							Type       = "Restart Computer"
							GroupName  = "State Restore"
							SubGroup   = "Cleanup before Sysprep"
							AddAfter   = "Action - CleanupBeforeSysprep"
						}
					)
                }
            )

            #Custom folder/files to add to the MDT
            CustomSettings   = @(
                @{  
                    Ensure     = "Present"
                    Name       = "Extra"
                    SourcePath = "Extra"
					TestFiles  = @("Deploy\Scripts\LoadKVPInWinPE.vbs",
								   "KVP\devcon.exe",
								   "KVP\iccoinstall2.dll",
								   "KVP\icsvc.dll",
								   "KVP\vmapplicationhealthmonitorproxy.dll",
								   "KVP\vmicres.dll",
								   "KVP\vmictimeprovider.dll",
								   "KVP\vmrdvcore.dll",
								   "KVP\wvmic.inf"
								  )
                }
                @{  
                    Ensure     = "Present"
                    Name       = "Scripts"
                    SourcePath = "Scripts"
					TestFiles  = "ReadKVPData.vbs"
                }
            )

            #Custom settings and boot ini file management
            CustomizeIniFiles  = @(
                @{  
                    Ensure               = "Present"
                    Name                 = "CustomSettingsIni"
                    Path                 = "\Control\CustomSettings.ini"
                    Company              = "Build Lab"
                    TimeZoneName         = "Ekaterinburg Standard Time"
                    WSUSServer           = "http://fqdn:port"
                    UserLocale           = "en-US"
                    KeyboardLocale       = "en-US;ru-RU"
                }
                @{  
                    Ensure           = "Present"
                    Name             = "BootstrapIni"
                    Path             = "\Control\Bootstrap.ini"
                }
            )

            #Boot image creation and management
            BootImage  = @(
                @{  
                    Version    = "1.0"
                    ExtraDirectory = "Extra"
                    BackgroundFile = "%INSTALLDIR%\Samples\Background.bmp"
                    LiteTouchWIMDescription = "MDT Build Lab"
                }
            )
        }
    ); 
}