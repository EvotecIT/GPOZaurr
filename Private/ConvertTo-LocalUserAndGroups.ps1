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
