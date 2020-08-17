function ConvertTo-XMLNested {
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