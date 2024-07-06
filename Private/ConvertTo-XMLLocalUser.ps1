function ConvertTo-XMLLocalUser {
    <#
    .SYNOPSIS
    Converts Group Policy Objects (GPO) data to XML format for local users.

    .DESCRIPTION
    This function converts GPO data to XML format specifically for local users. It extracts relevant user settings from the GPO data and organizes them into a structured XML format.

    .PARAMETER GPO
    Specifies the GPO object containing user data to be converted.

    .PARAMETER SingleObject
    Indicates whether to convert a single user object or multiple user objects.

    .EXAMPLE
    ConvertTo-XMLLocalUser -GPO $myGPO -SingleObject
    Converts a single GPO object to XML format for local users.

    .EXAMPLE
    ConvertTo-XMLLocalUser -GPO $myGPO
    Converts multiple GPO objects to XML format for local users.

    #>
    
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