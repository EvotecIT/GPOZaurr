function Get-XMLGPO {
    [cmdletBinding()]
    param(
        [XML] $XMLContent
    )
    [PsCustomObject] @{
        'Name'                              = $XMLContent.GPO.Name
        'Links'                             = $XMLContent.GPO.LinksTo #| Select-Object -ExpandProperty SOMPath
        'Enabled'                           = $XMLContent.GPO.GpoStatus
        'GUID'                              = $XMLContent.GPO.Identifier.Identifier.InnerText

        'Domain'                            = $XMLContent.GPO.Identifier.Domain.'#text'

        'ComputerSettingsAvailable'         = if ($null -eq $XMLContent.GPO.Computer.ExtensionData) { $false } else { $true }
        'ComputerSettingsStatus'            = if ($XMLContent.GPO.Computer.VersionDirectory -eq 0 -and $XMLContent.GPO.Computer.VersionSysvol -eq 0) { "NeverModified" } else { "Modified" }
        'ComputerEnabled'                   = [bool] $XMLContent.GPO.Computer.Enabled
        'ComputerSetttingsVersionIdentical' = if ($XMLContent.GPO.Computer.VersionDirectory -eq $XMLContent.GPO.Computer.VersionSysvol) { $true } else { $false }
        'ComputerSettings'                  = $XMLContent.GPO.Computer.ExtensionData.Extension

        'UserSettingsAvailable'             = if ($null -eq $XMLContent.GPO.User.ExtensionData) { $false } else { $true }
        'UserEnabled'                       = [bool] $XMLContent.GPO.User.Enabled
        'UserSettingsStatus'                = if ($XMLContent.GPO.User.VersionDirectory -eq 0 -and $XMLContent.GPO.User.VersionSysvol -eq 0) { "NeverModified" } else { "Modified" }
        'UserSettingsVersionIdentical'      = if ($XMLContent.GPO.User.VersionDirectory -eq $XMLContent.GPO.User.VersionSysvol) { $true } else { $false }
        'UserSettings'                      = $XMLContent.GPO.User.ExtensionData.Extension


        # 'CreationTime'                      = [DateTime] $XMLContent.GPO.CreatedTime
        # 'ModificationTime'                  = [DateTime] $XMLContent.GPO.ModifiedTime
        # 'ReadTime'                          = [DateTime] $XMLContent.GPO.ReadTime

        'WMIFilter'                         = $GPO.WmiFilter.name
        'WMIFilterDescription'              = $GPO.WmiFilter.Description
        'Path'                              = $GPO.Path
        #'SDDL'                      = if ($Splitter -ne '') { $XMLContent.GPO.SecurityDescriptor.SDDL.'#text' -join $Splitter } else { $XMLContent.GPO.SecurityDescriptor.SDDL.'#text' }
        'ACL'                               = $XMLContent.GPO.SecurityDescriptor.Permissions.TrusteePermissions | ForEach-Object -Process {
            [PsCustomObject] @{
                'User'            = $_.trustee.name.'#Text'
                'Permission Type' = $_.type.PermissionType
                'Inherited'       = $_.Inherited
                'Permissions'     = $_.Standard.GPOGroupedAccessEnum
            }
        }

    }
    #break
}