function ConvertTo-XMLSystemServices {
    <#
    .SYNOPSIS
    Converts Group Policy Objects (GPO) data to an XML format for System Services.

    .DESCRIPTION
    This function takes a GPO object and converts its data into an XML format suitable for System Services. It organizes the GPO data including service names, startup modes, security auditing status, permissions, and security descriptors.

    .PARAMETER GPO
    Specifies the GPO object to be converted to XML format.

    .PARAMETER SingleObject
    Indicates whether to convert a single GPO object or multiple GPO objects.

    .EXAMPLE
    ConvertTo-XMLSystemServices -GPO $myGPO -SingleObject
    Converts a single GPO object $myGPO to XML format for System Services.

    .EXAMPLE
    ConvertTo-XMLSystemServices -GPO $myGPO
    Converts multiple GPO objects to XML format for System Services.

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