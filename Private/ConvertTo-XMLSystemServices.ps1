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