function ConvertTo-XMLLocalGroups {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [switch] $SingleObject
    )

    if ($SingleObject) {
        $CreateGPO = [ordered]@{
            DisplayName = $GPO.DisplayName
            DomainName  = $GPO.DomainName
            GUID        = $GPO.GUID
            GpoType     = $GPO.GpoType
            #GpoCategory = $GPOEntry.GpoCategory
            #GpoSettings = $GPOEntry.GpoSettings
            Count       = 0
            Settings    = $null
        }
        if (-not $GPO.DataSet.Group) {
            continue
        }
        [Array] $CreateGPO['Settings'] = foreach ($Group in $GPO.DataSet.Group) {
            # We're mostly interested in Members
            [Array] $Members = foreach ($Member in $Group.Properties.Members.Member) {
                [ordered] @{
                    MemberName   = $Member.Name
                    MemberAction = $Member.Action
                    MemberSID    = $Member.SID
                }
            }
            # if we have no members we create dummy object to make sure we can use foreach below
            if ($Members.Count -eq 0) {
                $Members = @(
                    [ordered] @{
                        MemberName   = $null
                        MemberAction = $null
                        MemberSID    = $null
                    }
                )
            }
            foreach ($Member in $Members) {
                $GroupObject = [ordered]@{
                    Changed         = [DateTime] $Group.Changed
                    GPOSettingOrder = $Group.GPOSettingOrder
                    Name            = $Group.name
                    Action          = $Script:Actions["$($Group.Properties.action)"]
                    GroupName       = $Group.Properties.groupName       #: Administrators (built -in )
                    NewName         = $Group.Properties.newName         #:
                    Description     = $Group.Properties.description     #:
                    DeleteAllUsers  = if ($Group.Properties.deleteAllUsers -eq '1') { 'Enabled' } elseif ($Group.Properties.deleteAllUsers -eq '0') { 'Disabled' } else { $Group.Properties.deleteAllUsers };
                    DeleteAllGroups = if ($Group.Properties.deleteAllGroups -eq '1') { 'Enabled' } elseif ($Group.Properties.deleteAllGroups -eq '0') { 'Disabled' } else { $Group.Properties.deleteAllGroups };
                    RemoveAccounts  = if ($Group.Properties.removeAccounts -eq '1') { 'Enabled' } elseif ($Group.Properties.removeAccounts -eq '0') { 'Disabled' } else { $Group.Properties.removeAccounts };
                    GroupSid        = $Group.Properties.groupSid        #: S - 1 - 5 - 32 - 544
                }
                $Last = [ordered] @{
                    Uid                                   = $Group.uid             #: {8F435B0A-CD15-464E-85F3-B6A55B9E816A}: {8F435B0A-CD15-464E-85F3-B6A55B9E816A}
                    RunInLoggedOnUserSecurityContext      = if ($Group.userContext -eq '1') { 'Enabled' } elseif ($Group.userContext -eq '0') { 'Disabled' } else { $Group.userContext };
                    RemoveThisItemWhenItIsNoLongerApplied = if ($Group.removePolicy -eq '1') { 'Enabled' } elseif ($Group.removePolicy -eq '0') { 'Disabled' } else { $Group.removePolicy };
                    Filters                               = $Group.Filters         #::
                }
                # Merging GPO with Member
                $GroupObject = $GroupObject + $Member + $Last
                [PSCustomObject] $GroupObject
            }
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Group in $GPO.DataSet.Group) {
            # We're mostly interested in Members
            [Array] $Members = foreach ($Member in $Group.Properties.Members.Member) {
                [ordered] @{
                    MemberName   = $Member.Name
                    MemberAction = $Member.Action
                    MemberSID    = $Member.SID
                }
            }
            # if we have no members we create dummy object to make sure we can use foreach below
            if ($Members.Count -eq 0) {
                $Members = @(
                    [ordered] @{
                        MemberName   = $null
                        MemberAction = $null
                        MemberSID    = $null
                    }
                )
            }
            foreach ($Member in $Members) {
                $CreateGPO = [ordered]@{
                    DisplayName     = $GPO.DisplayName
                    DomainName      = $GPO.DomainName
                    GUID            = $GPO.GUID
                    GpoType         = $GPO.GpoType
                    #GpoCategory          = $GPO.GpoCategory   #: SecuritySettings
                    #GpoSettings          = $GPO.GpoSettings   #: SecurityOptions
                    Changed         = [DateTime] $Group.Changed
                    GPOSettingOrder = $Group.GPOSettingOrder
                    Name            = $Group.name
                    Action          = $Script:Actions["$($Group.Properties.action)"]
                    GroupName       = $Group.Properties.groupName       #: Administrators (built -in )
                    NewName         = $Group.Properties.newName         #:
                    Description     = $Group.Properties.description     #:
                    DeleteAllUsers  = if ($Group.Properties.deleteAllUsers -eq '1') { 'Enabled' } elseif ($Group.Properties.deleteAllUsers -eq '0') { 'Disabled' } else { $Group.Properties.deleteAllUsers };
                    DeleteAllGroups = if ($Group.Properties.deleteAllGroups -eq '1') { 'Enabled' } elseif ($Group.Properties.deleteAllGroups -eq '0') { 'Disabled' } else { $Group.Properties.deleteAllGroups };
                    RemoveAccounts  = if ($Group.Properties.removeAccounts -eq '1') { 'Enabled' } elseif ($Group.Properties.removeAccounts -eq '0') { 'Disabled' } else { $Group.Properties.removeAccounts };
                    GroupSid        = $Group.Properties.groupSid        #: S - 1 - 5 - 32 - 544
                }
                $Last = [ordered] @{
                    Uid                                   = $Group.uid             #: {8F435B0A-CD15-464E-85F3-B6A55B9E816A}: {8F435B0A-CD15-464E-85F3-B6A55B9E816A}
                    RunInLoggedOnUserSecurityContext      = if ($Group.userContext -eq '1') { 'Enabled' } elseif ($Group.userContext -eq '0') { 'Disabled' } else { $Group.userContext };
                    RemoveThisItemWhenItIsNoLongerApplied = if ($Group.removePolicy -eq '1') { 'Enabled' } elseif ($Group.removePolicy -eq '0') { 'Disabled' } else { $Group.removePolicy };
                    Filters                               = $Group.Filters         #::
                }
                # Merging GPO with Member
                $CreateGPO = $CreateGPO + $Member + $Last
                $CreateGPO['Linked'] = $GPO.Linked
                $CreateGPO['LinksCount'] = $GPO.LinksCount
                $CreateGPO['Links'] = $GPO.Links
                [PSCustomObject] $CreateGPO
            }
        }
    }
}
