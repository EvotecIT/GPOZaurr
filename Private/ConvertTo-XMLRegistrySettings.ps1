function ConvertTo-XMLRegistrySettings {
    <#
    .SYNOPSIS
    Converts Group Policy Object (GPO) settings to XML format.

    .DESCRIPTION
    This function converts the settings of a Group Policy Object (GPO) to XML format. It can be used to export GPO settings for analysis or backup purposes.

    .PARAMETER GPO
    Specifies the Group Policy Object (GPO) to convert to XML format.

    .PARAMETER SingleObject
    Indicates whether to convert a single GPO object or multiple GPO objects.

    .EXAMPLE
    ConvertTo-XMLRegistrySettings -GPO $myGPO -SingleObject
    Converts a single GPO object to XML format.

    .EXAMPLE
    ConvertTo-XMLRegistrySettings -GPO $myGPO
    Converts multiple GPO objects to XML format.

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

        [Array] $CreateGPO['Settings'] = Get-XMLNestedRegistry -GPO $GPO -DataSet $GPO.DataSet
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        Get-XMLNestedRegistry -GPO $GPO -DataSet $GPO.DataSet
    }
}