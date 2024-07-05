function ConvertTo-XMLPrinter {
    <#
    .SYNOPSIS
    Converts Group Policy Objects (GPO) to an XML printer format.

    .DESCRIPTION
    This function converts GPO objects to an XML printer format, providing detailed information about printers and printer connections.

    .PARAMETER GPO
    Specifies the GPO object to be converted.

    .PARAMETER SingleObject
    Indicates whether to convert a single GPO object or multiple GPO objects.

    .EXAMPLE
    ConvertTo-XMLPrinter -GPO $myGPO -SingleObject
    Converts a single GPO object $myGPO to an XML printer format.

    .EXAMPLE
    ConvertTo-XMLPrinter -GPO $myGPO
    Converts multiple GPO objects to an XML printer format.

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
            foreach ($Type in @('SharedPrinter', 'PortPrinter', 'LocalPrinter')) {
                foreach ($Entry in $GPO.DataSet.$Type) {
                    if ($Entry) {
                        ConvertTo-XMLPrinterInternal -GPO $GPO -Entry $Entry -Type $Type -Limited
                    }
                }
            }
            if ($GPO.GpoCategory -eq 'PrinterConnectionSettings') {
                foreach ($Entry in $GPO.DataSet) {
                    ConvertTo-XMLPrinterInternal -GPO $GPO -Entry $Entry -Type 'PrinterConnections' -Limited
                }
            }
        )
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Type in @('SharedPrinter', 'PortPrinter', 'LocalPrinter')) {
            foreach ($Entry in $GPO.DataSet.$Type) {
                if ($Entry) {
                    ConvertTo-XMLPrinterInternal -GPO $GPO -Entry $Entry -Type $Type
                }
            }
        }
        if ($GPO.GpoCategory -eq 'PrinterConnectionSettings') {
            foreach ($Entry in $GPO.DataSet) {
                ConvertTo-XMLPrinterInternal -GPO $GPO -Entry $Entry -Type 'PrinterConnections'
            }
        }
    }
}