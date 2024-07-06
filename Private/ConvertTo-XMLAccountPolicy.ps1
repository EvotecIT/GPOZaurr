function ConvertTo-XMLAccountPolicy {
    <#
    .SYNOPSIS
    Converts a PowerShell custom object representing an account policy into XML format.

    .DESCRIPTION
    This function takes a PowerShell custom object representing an account policy and converts it into XML format for storage or transmission.

    .PARAMETER GPO
    The PowerShell custom object representing the account policy.

    .PARAMETER SingleObject
    Indicates whether to convert a single object or multiple objects.

    .EXAMPLE
    ConvertTo-XMLAccountPolicy -GPO $accountPolicyObject -SingleObject

    Description:
    Converts the $accountPolicyObject into XML format for a single object.

    .EXAMPLE
    $accountPolicies | ConvertTo-XMLAccountPolicy -SingleObject

    Description:
    Converts multiple account policies in $accountPolicies into XML format for each object.
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
        [Array] $CreateGPO['Settings'] = @(
            $Settings = [ordered]@{
                DisplayName           = $GPO.DisplayName
                DomainName            = $GPO.DomainName
                GUID                  = $GPO.GUID
                GpoType               = $GPO.GpoType
                #GpoCategory = $GPOEntry.GpoCategory
                #GpoSettings = $GPOEntry.GpoSettings
                ClearTextPassword     = 'Not Set'
                LockoutBadCount       = 'Not Set'
                LockoutDuration       = 'Not Set'
                MaximumPasswordAge    = 'Not Set'
                MinimumPasswordAge    = 'Not Set'
                MinimumPasswordLength = 'Not Set'
                PasswordComplexity    = 'Not Set'
                PasswordHistorySize   = 'Not Set'
                ResetLockoutCount     = 'Not Set'
                MaxClockSkew          = 'Not Set'
                MaxRenewAge           = 'Not Set'
                MaxServiceAge         = 'Not Set'
                MaxTicketAge          = 'Not Set'
                TicketValidateClient  = 'Not Set'
            }
            foreach ($GPOEntry in $GPO.DataSet) {
                if ($GPOEntry.SettingBoolean) {
                    $Settings[$($GPOEntry.Name)] = if ($GPOEntry.SettingBoolean -eq 'true') { 'Enabled' } elseif ($GPOEntry.SettingBoolean -eq 'false') { 'Disabled' } else { 'Not set' };
                } elseif ($GPOEntry.SettingNumber) {
                    $Settings[$($GPOEntry.Name)] = [int64] $GPOEntry.SettingNumber
                }
            }
            [PSCustomObject] $Settings
        )


        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {



        $CreateGPO = [ordered]@{
            DisplayName           = $GPO.DisplayName
            DomainName            = $GPO.DomainName
            GUID                  = $GPO.GUID
            GpoType               = $GPO.GpoType
            #GpoCategory = $GPOEntry.GpoCategory
            #GpoSettings = $GPOEntry.GpoSettings
            ClearTextPassword     = 'Not Set'
            LockoutBadCount       = 'Not Set'
            LockoutDuration       = 'Not Set'
            MaximumPasswordAge    = 'Not Set'
            MinimumPasswordAge    = 'Not Set'
            MinimumPasswordLength = 'Not Set'
            PasswordComplexity    = 'Not Set'
            PasswordHistorySize   = 'Not Set'
            ResetLockoutCount     = 'Not Set'
            MaxClockSkew          = 'Not Set'
            MaxRenewAge           = 'Not Set'
            MaxServiceAge         = 'Not Set'
            MaxTicketAge          = 'Not Set'
            TicketValidateClient  = 'Not Set'
        }
        foreach ($GPOEntry in $GPO.DataSet) {
            if ($GPOEntry.SettingBoolean) {
                $CreateGPO[$($GPOEntry.Name)] = if ($GPOEntry.SettingBoolean -eq 'true') { 'Enabled' } elseif ($GPOEntry.SettingBoolean -eq 'false') { 'Disabled' } else { 'Not set' };
            } elseif ($GPOEntry.SettingNumber) {
                $CreateGPO[$($GPOEntry.Name)] = [int64] $GPOEntry.SettingNumber
            }
        }
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    }
}