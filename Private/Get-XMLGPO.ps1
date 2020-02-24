function Get-XMLGPO {
    [cmdletBinding()]
    param(
        [XML] $XMLContent
    )
    if ($XMLContent.GPO.LinksTo) {
        $Linked = $true
        $LinksCount = ([Array] $XMLContent.GPO.LinksTo).Count
    } else {
        $Linked = $false
        $LinksCount = 0
    }

    # Find proper values for enabled/disabled user/computer settings
    if ($XMLContent.GPO.Computer.Enabled -eq 'False') {
        $ComputerEnabled = $false
    } elseif ($XMLContent.GPO.Computer.Enabled -eq 'True') {
        $ComputerEnabled = $true
    }
    if ($XMLContent.GPO.User.Enabled -eq 'False') {
        $UserEnabled = $false
    } elseif ($XMLContent.GPO.User.Enabled -eq 'True') {
        $UserEnabled = $true
    }
    # Translate Enabled to same as GPO GUI
    if ($UserEnabled -eq $True -and $ComputerEnabled -eq $true) {
        $Enabled = 'Enabled'
    } elseif ($UserEnabled -eq $false -and $ComputerEnabled -eq $false) {
        $Enabled = 'All settings disabled'
    }elseif ($UserEnabled -eq $true -and $ComputerEnabled -eq $false) {
        $Enabled = 'Computer configuration settings disabled'
    }elseif ($UserEnabled -eq $false -and $ComputerEnabled -eq $true) {
        $Enabled = 'User configuration settings disabled'
    }

    [PsCustomObject] @{
        'Name'                              = $XMLContent.GPO.Name
        'Domain'                            = $XMLContent.GPO.Identifier.Domain.'#text'
        'GUID'                              = $XMLContent.GPO.Identifier.Identifier.InnerText
        'Linked'                            = $Linked
        'LinksCount'                        = $LinksCount
        'Enabled'                           = $Enabled
        'ComputerEnabled'                   = $ComputerEnabled
        'UserEnabled'                       = $UserEnabled
        'ComputerSettingsAvailable'         = if ($null -eq $XMLContent.GPO.Computer.ExtensionData) { $false } else { $true }
        'UserSettingsAvailable'             = if ($null -eq $XMLContent.GPO.User.ExtensionData) { $false } else { $true }
        'ComputerSettingsStatus'            = if ($XMLContent.GPO.Computer.VersionDirectory -eq 0 -and $XMLContent.GPO.Computer.VersionSysvol -eq 0) { "NeverModified" } else { "Modified" }
        'ComputerSetttingsVersionIdentical' = if ($XMLContent.GPO.Computer.VersionDirectory -eq $XMLContent.GPO.Computer.VersionSysvol) { $true } else { $false }
        'ComputerSettings'                  = $XMLContent.GPO.Computer.ExtensionData.Extension
        'UserSettingsStatus'                = if ($XMLContent.GPO.User.VersionDirectory -eq 0 -and $XMLContent.GPO.User.VersionSysvol -eq 0) { "NeverModified" } else { "Modified" }
        'UserSettingsVersionIdentical'      = if ($XMLContent.GPO.User.VersionDirectory -eq $XMLContent.GPO.User.VersionSysvol) { $true } else { $false }
        'UserSettings'                      = $XMLContent.GPO.User.ExtensionData.Extension

        'CreationTime'                      = [DateTime] $XMLContent.GPO.CreatedTime
        'ModificationTime'                  = [DateTime] $XMLContent.GPO.ModifiedTime
        'ReadTime'                          = [DateTime] $XMLContent.GPO.ReadTime

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
        'Links'                             = $XMLContent.GPO.LinksTo #| Select-Object -ExpandProperty SOMPath

    }
    #break
}