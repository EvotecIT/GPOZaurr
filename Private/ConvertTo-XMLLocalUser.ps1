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