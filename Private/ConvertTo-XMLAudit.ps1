function ConvertTo-XMLAudit {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [switch] $FullObject
    )
    $CreateGPO = [ordered]@{
        DisplayName          = $GPO.DisplayName
        DomainName           = $GPO.DomainName
        GUID                 = $GPO.GUID
        GpoType              = $GPO.GpoType
        #GpoCategory = $GPOEntry.GpoCategory
        #GpoSettings = $GPOEntry.GpoSettings
        AuditAccountLogon    = 'No auditing'
        AuditAccountManage   = 'No auditing'
        AuditDSAccess        = 'No auditing'
        AuditLogonEvents     = 'No auditing'
        AuditObjectAccess    = 'No auditing'
        AuditPolicyChange    = 'No auditing'
        AuditPrivilegeUse    = 'No auditing'
        AuditProcessTracking = 'No auditing'
        AuditSystemEvents    = 'No auditing'
    }
    foreach ($GPOEntry in $GPO.DataSet) {
        $SuccessAttempts = try { [bool]::Parse($GPOEntry.SuccessAttempts) } catch { $null };
        $FailureAttempts = try { [bool]::Parse($GPOEntry.FailureAttempts) } catch { $null };
        if ($SuccessAttempts -and $FailureAttempts) {
            $Setting = 'Success, Failure'
        } elseif ($SuccessAttempts) {
            $Setting = 'Success'
        } elseif ($FailureAttempts) {
            $Setting = 'Failure'
        } else {
            $Setting = 'No auditing'
        }
        $CreateGPO["$($GPOEntry.Name)"] = $Setting
    }
    $CreateGPO['Linked'] = $GPO.Linked
    $CreateGPO['LinksCount'] = $GPO.LinksCount
    $CreateGPO['Links'] = $GPO.Links
    [PSCustomObject] $CreateGPO
}