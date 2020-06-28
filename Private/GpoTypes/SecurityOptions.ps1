$SecurityOptions = @{
    Category           = 'SecuritySettings'
    Settings           = 'SecurityOptions'
    # This is to make sure we're not loosing anything
    # We will detect this and if something is missing provide details
    PossibleProperties = @(
        'KeyName'
        'SettingNumber'
        'Display'
        'SystemAccessPolicyName'
        'SettingString'
    )
    Translate          = [ordered] @{
        'KeyName'                = 'KeyName'
        'KeyDisplayName'         = 'Display', 'Name'
        'KeyDisplayUnits'        = 'Display', 'Units'
        'KeyDisplayBoolean'      = 'Display', 'DisplayBoolean'
        'KeyDisplayString'       = 'Display', 'DisplayString'
        'SystemAccessPolicyName' = 'SystemAccessPolicyName'
        'SettingString'          = 'SettingString'
        'SettingNumber'          = 'SettingNumber'
    }
    Types              = [ordered] @{
        'KeyDisplayBoolean' = { try { [bool]::Parse($args) } catch { $null } }
    }
}

$LugsSettingsLocalUsersAndGroups = @{
    PossibleProperties = @(
        'clsid'
        'Group'
        'User'
    )
    CustomCode         = {

    }
    <#
    LoopOver           = @{
        User  = @{

        }
        Group = @{

        }
    }
    #>


    <#
    Translate          = [ordered] @{
        Name               =  #= $Entry.name
        Changed            =  #= [DateTime]  $Entry.changed
        GPOSettingOrder    =  #= $Entry.GPOSettingOrder
        Filters            =  #= $Entry.Filters
        ActionType         =  #= $NestedType
        Action             =  #= $Entry.Properties.Action
        UserName           =  #= $Entry.Properties.userName
        NewName            =  #= $Entry.Properties.newName
        Description        =  #= $Entry.Properties.description
        DeleteAllUsers     =  #= [bool] $Entry.Properties.deleteAllUsers
        DeleteAllGroups    =  #= [bool] $Entry.Properties.deleteAllGroups
        RemoveAccounts     =  #= [bool] $Entry.Properties.removeAccounts
        GroupSid           =  #= $Entry.Properties.groupSid
        GroupName          =  #= $Entry.Properties.groupName
        MembersName        =  #= $Member.Name
        MembersAction      =  #= $Member.Action
        MembersSid         =  #= $Member.Sid
        FullName           =  #= $Entry.Properties.fullName
        AccountCpassword   =  #= $Entry.Properties.cpassword
        AccountChangeLogon =  #= [bool] $Entry.Properties.changeLogon
        AccountNoChange    =  #= [bool] $Entry.Properties.noChange
        AccountNeverExpires=  #= [bool] $Entry.Properties.neverExpires
        AccountDisabled    =  #= [bool] $Entry.Properties.acctDisabled
        SubAuthority       =  #= $Entry.Properties.subAuthority
    }
    #>
}