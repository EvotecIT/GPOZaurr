function ConvertTo-XMLWindowsFirewall {
    <#
    .SYNOPSIS
    Converts a Group Policy Object (GPO) to an XML representation for Windows Firewall settings.

    .DESCRIPTION
    This function takes a GPO object and converts it into an XML format suitable for Windows Firewall settings. It can handle single GPO objects or multiple GPO objects.

    .PARAMETER GPO
    Specifies the Group Policy Object to be converted to XML.

    .PARAMETER SingleObject
    Indicates whether to convert a single GPO object or multiple GPO objects.

    .EXAMPLE
    ConvertTo-XMLWindowsFirewall -GPO $myGPO -SingleObject
    Converts a single GPO object $myGPO to an XML representation for Windows Firewall settings.

    .EXAMPLE
    $GPOs | ConvertTo-XMLWindowsFirewall
    Converts multiple GPO objects in the $GPOs array to XML representations for Windows Firewall settings.

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
        [Array] $CreateGPO['Settings'] = foreach ($Policy in $GPO.DataSet) {
            [PSCustomObject] @{
                Name    = $Policy.LocalName
                Version = $Policy.PolicyVersion.Value
            }
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Policy in $GPO.DataSet) {
            [PSCustomObject]@{
                DisplayName = $GPO.DisplayName
                DomainName  = $GPO.DomainName
                GUID        = $GPO.GUID
                GpoType     = $GPO.GpoType
                Name        = $Policy.LocalName
                Version     = $Policy.PolicyVersion.Value
                Linked      = $GPO.Linked
                LinksCount  = $GPO.LinksCount
                Links       = $GPO.Links
            }
        }
    }
}