function ConvertTo-SystemServices {
    [cmdletBinding()]
    param(
        [Array] $GPOList
    )
    foreach ($GPOEntry in $GPOList) {
        $CreateGPO = [ordered]@{
            DisplayName                = $GPOEntry.DisplayName   #: WO_SEC_NTLM_Auth_Level
            DomainName                 = $GPOEntry.DomainName    #: area1.local
            GUID                       = $GPOEntry.GUID          #: 364B095E-C7BF-4CC1-9BFA-393BD38975E5
            GpoType                    = $GPOEntry.GpoType       #: Computer
            GpoCategory                = $GPOEntry.GpoCategory   #: SecuritySettings
            GpoSettings                = $GPOEntry.GpoSettings   #: SecurityOptions
            ServiceName                = $GPOEntry.Name
            ServiceStartUpMode         = $GPOEntry.StartUpMode
            SecurityAuditingPresent    = try { [bool]::Parse($GPOEntry.SecurityDescriptor.AuditingPresent.'#text') } catch { $null };
            SecurityPermissionsPresent = try { [bool]::Parse($GPOEntry.SecurityDescriptor.PermissionsPresent.'#text') } catch { $null };
            SecurityDescriptor         = $GPOEntry.SecurityDescriptor
        }
        $CreateGPO['Linked'] = $GPOEntry.Linked        #: True
        $CreateGPO['LinksCount'] = $GPOEntry.LinksCount    #: 1
        $CreateGPO['Links'] = $GPOEntry.Links         #: area1.local
        [PSCustomObject] $CreateGPO
    }
}

function ConvertTo-XMLSystemServices {
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
        [Array] $CreateGPO['Settings'] = foreach ($GPOEntry in $GPO.DataSet) {
            [PSCustomObject] @{
                ServiceName                = $GPOEntry.Name
                ServiceStartUpMode         = $GPOEntry.StartUpMode
                SecurityAuditingPresent    = try { [bool]::Parse($GPOEntry.SecurityDescriptor.AuditingPresent.'#text') } catch { $null };
                SecurityPermissionsPresent = try { [bool]::Parse($GPOEntry.SecurityDescriptor.PermissionsPresent.'#text') } catch { $null };
                SecurityDescriptor         = $GPOEntry.SecurityDescriptor
            }
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($GPOEntry in $GPO.DataSet) {
            $CreateGPO = [ordered]@{
                DisplayName                = $GPO.DisplayName
                DomainName                 = $GPO.DomainName
                GUID                       = $GPO.GUID
                GpoType                    = $GPO.GpoType
                #GpoCategory = $GPOEntry.GpoCategory
                #GpoSettings = $GPOEntry.GpoSettings
                ServiceName                = $GPOEntry.Name
                ServiceStartUpMode         = $GPOEntry.StartUpMode
                SecurityAuditingPresent    = try { [bool]::Parse($GPOEntry.SecurityDescriptor.AuditingPresent.'#text') } catch { $null };
                SecurityPermissionsPresent = try { [bool]::Parse($GPOEntry.SecurityDescriptor.PermissionsPresent.'#text') } catch { $null };
                SecurityDescriptor         = $GPOEntry.SecurityDescriptor
            }
            $CreateGPO['Linked'] = $GPO.Linked
            $CreateGPO['LinksCount'] = $GPO.LinksCount
            $CreateGPO['Links'] = $GPO.Links
            [PSCustomObject] $CreateGPO
        }
    }
}