function ConvertTo-XMLNested {
    <#
    .SYNOPSIS
    Converts nested XML elements to a structured format for further processing.

    .DESCRIPTION
    This function recursively converts nested XML elements to a structured format for easier manipulation and analysis. It extracts properties from the XML elements and organizes them into a hierarchical structure.

    .PARAMETER CreateGPO
    Specifies the dictionary representing the XML structure being created.

    .PARAMETER Setting
    Specifies the XML element to be processed.

    .PARAMETER SkipNames
    Specifies an array of property names to skip during processing.

    .PARAMETER Name
    Specifies the name of the current XML element being processed.

    .EXAMPLE
    ConvertTo-XMLNested -CreateGPO $MyGPO -Setting $XmlSetting -SkipNames @('Name', 'Value') -Name 'Root'

    Description:
    Converts the nested XML element $XmlSetting into a structured format stored in $MyGPO, skipping properties 'Name' and 'Value', with the root element named 'Root'.

    .EXAMPLE
    $XmlElements | ForEach-Object { ConvertTo-XMLNested -CreateGPO $Output -Setting $_ -SkipNames @('ID') -Name 'Element' }

    Description:
    Processes multiple XML elements in $XmlElements, converting each into a structured format stored in $Output, skipping property 'ID', and naming each element 'Element'.
    #>
    [cmdletBinding()]
    param(
        [System.Collections.IDictionary] $CreateGPO,
        [System.Xml.XmlElement] $Setting,
        [string[]] $SkipNames,
        [string] $Name
    )

    $Properties = $Setting.PSObject.Properties.Name | Where-Object { $_ -notin $SkipNames }
    $TempName = $Name
    foreach ($Property in $Properties) {
        If ($Property -eq 'Value') {
            if ($Setting.$Property) {
                #$SubProperties = $Setting.$Property.PSObject.Properties.Name
                if ($Setting.$Property.Name) {
                    $Name = $Setting.$Property.Name
                } else {
                    if (-not $Name) {
                        $Name = 'Value'
                    }
                }
                if ($Setting.$Property.Number) {
                    $CreateGPO[$Name] = $Setting.$Property.Number
                } elseif ($Setting.$Property.String) {
                    $CreateGPO[$Name] = $Setting.$Property.String
                } else {
                    $CreateGPO[$Name] = $Setting.$Property

                    #throw
                }
            }
        } else {
            $Name = -join ($Name, $Property)
            $Name = Format-CamelCaseToDisplayName -Text $Name #-RemoveWhiteSpace -RemoveChar ',', '-', "'", '\(', '\)', ':'
            if ($Setting.$Property -is [System.Xml.XmlElement]) {
                #$SubPropeties = $Setting.$Property.PSObject.Properties.Name | Where-Object { $_ -notin $SkipNames }


                ConvertTo-XMLNested -Setting $Setting.$Property -CreateGPO $CreateGPO -Name $Name -SkipNames $SkipNames


            } else {
                $CreateGPO[$Name] = $Setting.$Property
            }
        }
        $Name = $TempName
    }
}