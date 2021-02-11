function ConvertTo-XMLWindowsFirewallConnectionSecurityAuthentiation {
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
        [Array] $CreateGPO['Settings'] = foreach ($Connection in $GPO.DataSet) {
            [PSCustomObject] @{
                Name               = $Connection.LocalName
                Version            = $Connection.Version
                ConnectionGUID     = $Connection.GUID
                Method             = $Connection.AuthenticationSuites.Method #: MachineCert
                CAName             = $Connection.AuthenticationSuites.CAName #: DC = xyz, DC = evotec, DC = ad, CN = ad-ADCS-CA
                CertAccountMapping = if ($Connection.AuthenticationSuites.CertAccountMapping -eq 'true') { $true } elseif ($Connection.AuthenticationSuites.CertAccountMapping -eq 'false') { $false } else { $Connection.AuthenticationSuites.CertAccountMapping }
                ExcludeCAName      = if ($Connection.AuthenticationSuites.ExcludeCAName -eq 'true') { $true } elseif ($Connection.AuthenticationSuites.ExcludeCAName -eq 'false') { $false } else { $Connection.AuthenticationSuites.ExcludeCAName }
                HealthCert         = if ($Connection.AuthenticationSuites.HealthCert -eq 'true') { $true } elseif ($Connection.AuthenticationSuites.HealthCert -eq 'false') { $false } else { $Connection.AuthenticationSuites.HealthCert }
            }
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Connection in $GPO.DataSet) {
            [PSCustomObject]@{
                DisplayName        = $GPO.DisplayName
                DomainName         = $GPO.DomainName
                GUID               = $GPO.GUID
                GpoType            = $GPO.GpoType
                Name               = $Connection.LocalName
                Version            = $Connection.Version
                ConnectionGUID     = $Connection.GUID
                Method             = $Connection.AuthenticationSuites.Method #: MachineCert
                CAName             = $Connection.AuthenticationSuites.CAName #: DC = xyz, DC = evotec, DC = ad, CN = ad-ADCS-CA
                CertAccountMapping = if ($Connection.AuthenticationSuites.CertAccountMapping -eq 'true') { $true } elseif ($Connection.AuthenticationSuites.CertAccountMapping -eq 'false') { $false } else { $Connection.AuthenticationSuites.CertAccountMapping }
                ExcludeCAName      = if ($Connection.AuthenticationSuites.ExcludeCAName -eq 'true') { $true } elseif ($Connection.AuthenticationSuites.ExcludeCAName -eq 'false') { $false } else { $Connection.AuthenticationSuites.ExcludeCAName }
                HealthCert         = if ($Connection.AuthenticationSuites.HealthCert -eq 'true') { $true } elseif ($Connection.AuthenticationSuites.HealthCert -eq 'false') { $false } else { $Connection.AuthenticationSuites.HealthCert }
                Linked             = $GPO.Linked
                LinksCount         = $GPO.LinksCount
                Links              = $GPO.Links
            }
        }
    }
}