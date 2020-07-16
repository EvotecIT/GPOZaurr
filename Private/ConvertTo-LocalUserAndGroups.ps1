function ConvertTo-LocalUserAndGroups {
    [cmdletBinding()]
    param(
        [Array] $GPOList
    )
    foreach ($GPOEntry in $GPOList) {
        foreach ($User in $GPOEntry.User) {
            $CreateGPO = [ordered]@{
                DisplayName      = $GPOEntry.DisplayName   #: WO_SEC_NTLM_Auth_Level
                DomainName       = $GPOEntry.DomainName    #: area1.local
                GUID             = $GPOEntry.GUID          #: 364B095E-C7BF-4CC1-9BFA-393BD38975E5
                GpoType          = $GPOEntry.GpoType       #: Computer
                GpoCategory      = $GPOEntry.GpoCategory   #: SecuritySettings
                GpoSettings      = $GPOEntry.GpoSettings   #: SecurityOptions
                Changed          = [DateTime] $User.Changed
                GPOSettingOrder  = $User.GPOSettingOrder
                UserAction       = $Script:Actions["$($User.Properties.action)"]       #: U
                UserNewName      = $User.Properties.newName      #:
                UserFullName     = $User.Properties.fullName     #:
                UserDescription  = $User.Properties.description  #:
                UserCpassword    = $User.Properties.cpassword    #:
                UserChangeLogon  = $User.Properties.changeLogon  #: 0
                UserNoChange     = $User.Properties.noChange     #: 0
                UserNeverExpires = $User.Properties.neverExpires #: 0
                UserAcctDisabled = $User.Properties.acctDisabled #: 0
                UserAubAuthority = $User.Properties.subAuthority #: RID_ADMIN
                UserUserName     = $User.Properties.userName     #: Administrator (built-in)
                UserMembers      = $User.Properties.Members      #:
            }
            $CreateGPO['Linked'] = $GPOEntry.Linked        #: True
            $CreateGPO['LinksCount'] = $GPOEntry.LinksCount    #: 1
            $CreateGPO['Links'] = $GPOEntry.Links         #: area1.local
            [PSCustomObject] $CreateGPO
        }
        foreach ($Group in $GPOEntry.Group) {
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
                    DisplayName          = $GPOEntry.DisplayName   #: WO_SEC_NTLM_Auth_Level
                    DomainName           = $GPOEntry.DomainName    #: area1.local
                    GUID                 = $GPOEntry.GUID          #: 364B095E-C7BF-4CC1-9BFA-393BD38975E5
                    GpoType              = $GPOEntry.GpoType       #: Computer
                    GpoCategory          = $GPOEntry.GpoCategory   #: SecuritySettings
                    GpoSettings          = $GPOEntry.GpoSettings   #: SecurityOptions
                    Changed              = [DateTime] $Group.Changed
                    GPOSettingOrder      = $Group.GPOSettingOrder
                    GroupUid             = $Group.uid             #: {8F435B0A-CD15-464E-85F3-B6A55B9E816A}: {8F435B0A-CD15-464E-85F3-B6A55B9E816A}
                    GroupUserContext     = $Group.userContext     #: 0: 0
                    GroupRemovePolicy    = $Group.removePolicy    #: 1: 1
                    #Properties      = $Group.Properties      #: Properties: Properties
                    Filters              = $Group.Filters         #::

                    GroupAction          = $Script:Actions["$($Group.Properties.action)"]          #: U
                    GroupNewName         = $Group.Properties.newName         #:
                    GroupDescription     = $Group.Properties.description     #:
                    GroupDeleteAllUsers  = $Group.Properties.deleteAllUsers  #: 0
                    GroupDeleteAllGroups = $Group.Properties.deleteAllGroups #: 0
                    GroupRemoveAccounts  = $Group.Properties.removeAccounts  #: 1
                    GroupSid             = $Group.Properties.groupSid        #: S - 1 - 5 - 32 - 544
                    GroupName            = $Group.Properties.groupName       #: Administrators (built -in )
                }
                # Merging GPO with Member
                $CreateGPO = $CreateGPO + $Member

                $CreateGPO['Linked'] = $GPOEntry.Linked        #: True
                $CreateGPO['LinksCount'] = $GPOEntry.LinksCount    #: 1
                $CreateGPO['Links'] = $GPOEntry.Links         #: area1.local
                [PSCustomObject] $CreateGPO
            }
        }
    }
}


function ConvertTo-XMLLocalUser {
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
        if (-not $GPO.DataSet.User) {
            continue
        }
        [Array] $CreateGPO['Settings'] = foreach ($User in $GPO.DataSet.User) {
            [PSCustomObject] @{
                Changed                       = [DateTime] $User.Changed
                GPOSettingOrder               = $User.GPOSettingOrder
                Action                        = $Script:Actions["$($User.Properties.action)"]
                UserName                      = $User.Properties.userName
                NewName                       = $User.Properties.newName
                FullName                      = $User.Properties.fullName
                Description                   = $User.Properties.description
                Password                      = $User.Properties.cpassword
                MustChangePasswordAtNextLogon = if ($User.Properties.changeLogon -eq '1') { $true } elseif ($User.Properties.changeLogon -eq '0') { $false } else { $User.Properties.changeLogon };
                CannotChangePassword          = if ($User.Properties.noChange -eq '1') { $true } elseif ($User.Properties.noChange -eq '0') { $false } else { $User.Properties.noChange };
                PasswordNeverExpires          = if ($User.Properties.neverExpires -eq '1') { $true } elseif ($User.Properties.neverExpires -eq '0') { $false } else { $User.Properties.neverExpires };
                AccountIsDisabled             = if ($User.Properties.acctDisabled -eq '1') { $true } elseif ($User.Properties.acctDisabled -eq '0') { $false } else { $User.Properties.acctDisabled };
                AccountExpires                = try { [DateTime] $User.Properties.expires } catch { $User.Properties.expires };
                SubAuthority                  = $User.Properties.subAuthority
            }
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($User in $GPO.DataSet.User) {
            $CreateGPO = [ordered]@{
                DisplayName                   = $GPO.DisplayName
                DomainName                    = $GPO.DomainName
                GUID                          = $GPO.GUID
                GpoType                       = $GPO.GpoType
                #GpoCategory      = $GPO.GpoCategory   #: SecuritySettings
                #GpoSettings      = $GPO.GpoSettings   #: SecurityOptions
                Changed                       = [DateTime] $User.Changed
                GPOSettingOrder               = $User.GPOSettingOrder
                Action                        = $Script:Actions["$($User.Properties.action)"]
                UserName                      = $User.Properties.userName
                NewName                       = $User.Properties.newName
                FullName                      = $User.Properties.fullName
                Description                   = $User.Properties.description
                Password                      = $User.Properties.cpassword
                MustChangePasswordAtNextLogon = if ($User.Properties.changeLogon -eq '1') { $true } elseif ($User.Properties.changeLogon -eq '0') { $false } else { $User.Properties.changeLogon };
                CannotChangePassword          = if ($User.Properties.noChange -eq '1') { $true } elseif ($User.Properties.noChange -eq '0') { $false } else { $User.Properties.noChange };
                PasswordNeverExpires          = if ($User.Properties.neverExpires -eq '1') { $true } elseif ($User.Properties.neverExpires -eq '0') { $false } else { $User.Properties.neverExpires };
                AccountIsDisabled             = if ($User.Properties.acctDisabled -eq '1') { $true } elseif ($User.Properties.acctDisabled -eq '0') { $false } else { $User.Properties.acctDisabled };
                AccountExpires                = try { [DateTime] $User.Properties.expires } catch { $User.Properties.expires };
                SubAuthority                  = $User.Properties.subAuthority
            }
            $CreateGPO['Linked'] = $GPO.Linked
            $CreateGPO['LinksCount'] = $GPO.LinksCount
            $CreateGPO['Links'] = $GPO.Links
            [PSCustomObject] $CreateGPO
        }
    }
}