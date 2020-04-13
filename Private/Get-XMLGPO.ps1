function Get-XMLGPO {
    [cmdletBinding()]
    param(
        [XML] $XMLContent,
        [Microsoft.GroupPolicy.Gpo] $GPO,
        [switch] $PermissionsOnly,
        [switch] $OwnerOnly,
        [System.Collections.IDictionary] $ADAdministrativeGroups
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
    } elseif ($UserEnabled -eq $true -and $ComputerEnabled -eq $false) {
        $Enabled = 'Computer configuration settings disabled'
    } elseif ($UserEnabled -eq $false -and $ComputerEnabled -eq $true) {
        $Enabled = 'User configuration settings disabled'
    }
    if (-not $PermissionsOnly) {
        if ($XMLContent.GPO.SecurityDescriptor.Owner.Name.'#text') {
            $AdministrativeGroup = $ADAdministrativeGroups['ByNetBIOS']["$($XMLContent.GPO.SecurityDescriptor.Owner.Name.'#text')"]
            $WellKnown = ConvertFrom-SID -SID $XMLContent.GPO.SecurityDescriptor.Owner.SID.'#text' -OnlyWellKnown
            if ($AdministrativeGroup) {
                $OwnerType = 'Administrative'
            } elseif ($WellKnown.Name) {
                $OwnerType = 'WellKnown'
            } else {
                $OwnerType = 'NonAdministrative'
            }
        } else {
            $OwnerType = 'EmptyOrUnknown'
        }
    }
    if ($PermissionsOnly) {
        [PsCustomObject] @{
            'DisplayName'    = $XMLContent.GPO.Name
            'DomainName'     = $XMLContent.GPO.Identifier.Domain.'#text'
            'GUID'           = $XMLContent.GPO.Identifier.Identifier.InnerText
            'Enabled'        = $Enabled
            'Name'           = $XMLContent.GPO.SecurityDescriptor.Owner.Name.'#text'
            'Sid'            = $XMLContent.GPO.SecurityDescriptor.Owner.SID.'#text'
            #'SidType'        = if (($XMLContent.GPO.SecurityDescriptor.Owner.SID.'#text').Length -le 10) { 'WellKnown' } else { 'Other' }
            'PermissionType' = 'Allow'
            'Inherited'      = $false
            'Permissions'    = 'Owner'
        }
        $XMLContent.GPO.SecurityDescriptor.Permissions.TrusteePermissions | ForEach-Object -Process {
            if ($_) {
                [PsCustomObject] @{
                    'DisplayName'    = $XMLContent.GPO.Name
                    'DomainName'     = $XMLContent.GPO.Identifier.Domain.'#text'
                    'GUID'           = $XMLContent.GPO.Identifier.Identifier.InnerText
                    'Enabled'        = $Enabled
                    'Name'           = $_.trustee.name.'#Text'
                    'Sid'            = $_.trustee.SID.'#Text'
                    #'SidType'        = if (($XMLContent.GPO.SecurityDescriptor.Owner.SID.'#text').Length -le 10) { 'WellKnown' } else { 'Other' }
                    'PermissionType' = $_.type.PermissionType
                    'Inherited'      = if ($_.Inherited -eq 'false') { $false } else { $true }
                    'Permissions'    = $_.Standard.GPOGroupedAccessEnum
                }
            }
        }
    } elseif ($OwnerOnly) {
        [PsCustomObject] @{
            'DisplayName' = $XMLContent.GPO.Name
            'DomainName'  = $XMLContent.GPO.Identifier.Domain.'#text'
            'GUID'        = $XMLContent.GPO.Identifier.Identifier.InnerText
            'Enabled'     = $Enabled
            'Owner'       = $XMLContent.GPO.SecurityDescriptor.Owner.Name.'#text'
            'OwnerSID'    = $XMLContent.GPO.SecurityDescriptor.Owner.SID.'#text'
            'OwnerType'   = $OwnerType
        }
    } else {
        [PsCustomObject] @{
            'DisplayName'                       = $XMLContent.GPO.Name
            'DomainName'                        = $XMLContent.GPO.Identifier.Domain.'#text'
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
            'DistinguishedName'                 = $GPO.Path
            'SDDL'                              = if ($Splitter -ne '') { $XMLContent.GPO.SecurityDescriptor.SDDL.'#text' -join $Splitter } else { $XMLContent.GPO.SecurityDescriptor.SDDL.'#text' }
            'Owner'                             = $XMLContent.GPO.SecurityDescriptor.Owner.Name.'#text'
            'OwnerSID'                          = $XMLContent.GPO.SecurityDescriptor.Owner.SID.'#text'
            'OwnerType'                         = $OwnerType
            'ACL'                               = @(
                [PsCustomObject] @{
                    'Name'           = $XMLContent.GPO.SecurityDescriptor.Owner.Name.'#text'
                    'Sid'            = $XMLContent.GPO.SecurityDescriptor.Owner.SID.'#text'
                    'PermissionType' = 'Allow'
                    'Inherited'      = $false
                    'Permissions'    = 'Owner'
                }
                $XMLContent.GPO.SecurityDescriptor.Permissions.TrusteePermissions | ForEach-Object -Process {
                    if ($_) {
                        [PsCustomObject] @{
                            'Name'           = $_.trustee.name.'#Text'
                            'Sid'            = $_.trustee.SID.'#Text'
                            'PermissionType' = $_.type.PermissionType
                            'Inherited'      = if ($_.Inherited -eq 'false') { $false } else { $true }
                            'Permissions'    = $_.Standard.GPOGroupedAccessEnum
                        }
                    }
                }
            )
            'Auditing'                          = if ($XMLContent.GPO.SecurityDescriptor.AuditingPresent.'#text' -eq 'true') { $true } else { $false }
            'Links'                             = $XMLContent.GPO.LinksTo | ForEach-Object -Process {
                if ($_) {
                    [PSCustomObject] @{
                        CanonicalName = $_.SOMPath
                        Enabled       = $_.Enabled
                        NoOverride    = $_.NoOverride
                    }
                }
            }
            <#
        SOMName SOMPath       Enabled NoOverride
        ------- -------       ------- ----------
        ad      ad.evotec.xyz true    false
        #>

            #| Select-Object -ExpandProperty SOMPath

        }
    }
    #break
}