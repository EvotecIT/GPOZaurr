function ConvertTo-XMLScripts {
    <#
    .SYNOPSIS
    Converts Group Policy Objects (GPO) to XML scripts.

    .DESCRIPTION
    This function converts GPO objects to XML scripts for further processing.

    .PARAMETER GPO
    Specifies the GPO object to be converted.

    .PARAMETER SingleObject
    Indicates whether to convert a single GPO object or multiple GPO objects.

    .EXAMPLE
    ConvertTo-XMLScripts -GPO $myGPO -SingleObject
    Converts a single GPO object to an XML script.

    .EXAMPLE
    ConvertTo-XMLScripts -GPO $myGPO
    Converts multiple GPO objects to XML scripts.

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
            Settings        = $null
        }
        [Array] $CreateGPO['Settings'] = foreach ($Script in $GPO.DataSet) {
            [PSCustomObject] @{
                Type       = $GPO.DataSet.Type
                Command    = $GPO.DataSet.Command
                Parameters = $GPO.DataSet.Parameters
                Order      = $GPO.DataSet.Order
                RunOrder   = $GPO.DataSet.RunOrder
            }
        }
        $CreateGPO['DataCount'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Script in $GPO.DataSet) {
            $CreateGPO = [ordered]@{
                DisplayName = $GPO.DisplayName
                DomainName  = $GPO.DomainName
                GUID        = $GPO.GUID
                GpoType     = $GPO.GpoType
                #GpoCategory = $GPOEntry.GpoCategory
                #GpoSettings = $GPOEntry.GpoSettings
                Type        = $Script.Type
                Command     = $Script.Command
                Parameters  = $Script.Parameters
                Order       = $Script.Order
                RunOrder    = $Script.RunOrder
            }
            $CreateGPO['Linked'] = $GPO.Linked
            $CreateGPO['LinksCount'] = $GPO.LinksCount
            $CreateGPO['Links'] = $GPO.Links
            [PSCustomObject] $CreateGPO
        }
    }
}