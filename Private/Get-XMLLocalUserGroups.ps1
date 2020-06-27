
function Get-XMLLocalUserGroups {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [System.Xml.XmlElement[]] $GPOOutput
    )
    if ($GPOOutput.LinksTo) {
        $Linked = $true
        $LinksCount = ([Array] $GPOOutput.LinksTo).Count
    } else {
        $Linked = $false
        $LinksCount = 0
    }
    foreach ($Type in @('User', 'Computer')) {
        if ($GPOOutput.$Type.ExtensionData.Extension.LocalUsersAndGroups) {
            foreach ($NestedType in @('User', 'Group')) {
                if ($GPOOutput.$Type.ExtensionData.Extension.LocalUsersAndGroups.$NestedType) {
                    foreach ($Entry in $GPOOutput.$Type.ExtensionData.Extension.LocalUsersAndGroups.$NestedType) {
                        if ($Entry.Properties.Members) {
                            foreach ($Members in $Entry.Properties.Members) {
                                foreach ($Member in $Members.Member) {
                                    [PSCustomObject] @{
                                        DisplayName         = $GPO.DisplayName
                                        DomainName          = $GPO.DomainName
                                        GUID                = $GPO.Guid
                                        Linked              = $Linked
                                        LinksCount          = $LinksCount
                                        GpoType             = $Type
                                        Name                = $Entry.name
                                        Changed             = [DateTime]  $Entry.changed
                                        GPOSettingOrder     = $Entry.GPOSettingOrder
                                        Filters             = $Entry.Filters
                                        ActionType          = $NestedType
                                        Action              = $Entry.Properties.Action
                                        UserName            = $Entry.Properties.userName
                                        NewName             = $Entry.Properties.newName
                                        Description         = $Entry.Properties.description
                                        DeleteAllUsers      = [bool] $Entry.Properties.deleteAllUsers
                                        DeleteAllGroups     = [bool] $Entry.Properties.deleteAllGroups
                                        RemoveAccounts      = [bool] $Entry.Properties.removeAccounts
                                        GroupSid            = $Entry.Properties.groupSid
                                        GroupName           = $Entry.Properties.groupName
                                        MembersName         = $Member.Name
                                        MembersAction       = $Member.Action
                                        MembersSid          = $Member.Sid
                                        FullName            = $Entry.Properties.fullName
                                        AccountCpassword    = $Entry.Properties.cpassword
                                        AccountChangeLogon  = [bool] $Entry.Properties.changeLogon
                                        AccountNoChange     = [bool] $Entry.Properties.noChange
                                        AccountNeverExpires = [bool] $Entry.Properties.neverExpires
                                        AccountDisabled     = [bool] $Entry.Properties.acctDisabled
                                        SubAuthority        = $Entry.Properties.subAuthority
                                    }
                                }
                            }
                        } else {
                            [PSCustomObject] @{
                                DisplayName         = $GPO.DisplayName
                                DomainName          = $GPO.DomainName
                                GUID                = $GPO.Guid
                                Linked              = $Linked
                                LinksCount          = $LinksCount
                                GpoType             = $Type
                                Name                = $Entry.name
                                Changed             = [DateTime] $Entry.changed
                                GPOSettingOrder     = $Entry.GPOSettingOrder
                                Filters             = $Entry.Filters
                                ActionType          = $NestedType
                                Action              = $Entry.Properties.Action
                                UserName            = $Entry.Properties.userName
                                NewName             = $Entry.Properties.newName
                                Description         = $Entry.Properties.description
                                DeleteAllUsers      = [bool] $Entry.Properties.deleteAllUsers
                                DeleteAllGroups     = [bool] $Entry.Properties.deleteAllGroups
                                RemoveAccounts      = [bool] $Entry.Properties.removeAccounts
                                GroupSid            = $Entry.Properties.groupSid
                                GroupName           = $Entry.Properties.groupName
                                MembersName         = $null
                                MembersAction       = $null
                                MembersSid          = $null
                                FullName            = $Entry.Properties.fullName
                                AccountCpassword    = $Entry.Properties.cpassword
                                AccountChangeLogon  = [bool] $Entry.Properties.changeLogon
                                AccountNoChange     = [bool] $Entry.Properties.noChange
                                AccountNeverExpires = [bool] $Entry.Properties.neverExpires
                                AccountDisabled     = [bool] $Entry.Properties.acctDisabled
                                SubAuthority        = $Entry.Properties.subAuthority
                            }
                        }
                    }
                }
            }
        }
    }
}