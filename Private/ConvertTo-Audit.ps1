function ConvertTo-Audit {
    [cmdletBinding()]
    param(
        [Array] $GPOList
    )
    foreach ($GPOEntry in $GPOList) {
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
        $CreateGPO = [ordered]@{
            DisplayName     = $GPOEntry.DisplayName   #: WO_SEC_NTLM_Auth_Level
            DomainName      = $GPOEntry.DomainName    #: area1.local
            GUID            = $GPOEntry.GUID          #: 364B095E-C7BF-4CC1-9BFA-393BD38975E5
            GpoType         = $GPOEntry.GpoType       #: Computer
            GpoCategory     = $GPOEntry.GpoCategory   #: SecuritySettings
            GpoSettings     = $GPOEntry.GpoSettings   #: SecurityOptions
            Policy          = $GPOEntry.Name
            Setting         = $Setting
            SuccessAttempts = $SuccessAttempts
            FailureAttempts = $FailureAttempts
        }
        $CreateGPO['Linked'] = $GPOEntry.Linked        #: True
        $CreateGPO['LinksCount'] = $GPOEntry.LinksCount    #: 1
        $CreateGPO['Links'] = $GPOEntry.Links         #: area1.local
        [PSCustomObject] $CreateGPO
    }
}