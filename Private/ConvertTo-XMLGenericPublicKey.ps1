function ConvertTo-XMLGenericPublicKey {
    <#
    .SYNOPSIS
    Converts a PSCustomObject representing a Group Policy Object (GPO) to an XML format.

    .DESCRIPTION
    This function takes a PSCustomObject representing a GPO and converts it to an XML format. It extracts specific properties from the GPO object and organizes them into a structured XML output.

    .PARAMETER GPO
    Specifies the PSCustomObject representing the GPO to be converted.

    .PARAMETER Category
    Specifies an array of strings representing categories to include in the XML output.

    .PARAMETER SingleObject
    Indicates whether to convert a single GPO object or multiple GPO objects.

    .EXAMPLE
    ConvertTo-XMLGenericPublicKey -GPO $MyGPO -Category @("Category1", "Category2") -SingleObject
    Converts the PSCustomObject $MyGPO to an XML format including categories "Category1" and "Category2" as a single object.

    .EXAMPLE
    $GPOs | ConvertTo-XMLGenericPublicKey -Category @("Category1") 
    Converts multiple GPOs in the $GPOs array to an XML format including category "Category1".

    #>
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [string[]] $Category,
        [switch] $SingleObject
    )
    $SkipNames = ('Name', 'LocalName', 'NamespaceURI', 'Prefix', 'NodeType', 'ParentNode', 'OwnerDocument', 'IsEmpty', 'Attributes', 'HasAttributes', 'SchemaInfo', 'InnerXml', 'InnerText', 'NextSibling', 'PreviousSibling', 'ChildNodes', 'FirstChild', 'LastChild', 'HasChildNodes', 'IsReadOnly', 'OuterXml', 'BaseURI', 'PreviousText')
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
        [Array] $CreateGPO['Settings'] = foreach ($Setting in $GPO.DataSet) {
            $SettingName = $Setting.Name -split ":"
            $MySettings = [ordered] @{
                CreatedTime         = $GPO.CreatedTime         # : 06.06.2020 18:03:36
                ModifiedTime        = $GPO.ModifiedTime        # : 17.06.2020 16:08:10
                ReadTime            = $GPO.ReadTime            # : 13.08.2020 10:15:37
                SecurityDescriptor  = $GPO.SecurityDescriptor  # : SecurityDescriptor
                FilterDataAvailable = $GPO.FilterDataAvailable # : True
            }
            $Name = $SettingName[1]
            #$Name = Format-ToTitleCase -Text $Setting.Name -RemoveWhiteSpace -RemoveChar ',', '-', "'", '\(', '\)', ':'
            $MySettings['Name'] = $Name # $Setting.Name

            ConvertTo-XMLNested -CreateGPO $MySettings -Setting $Setting -SkipNames $SkipNames #-Name $Name
            [PSCustomObject] $MySettings
        }

        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Setting in $GPO.DataSet) {
            $CreateGPO = [ordered]@{
                DisplayName = $GPO.DisplayName
                DomainName  = $GPO.DomainName
                GUID        = $GPO.GUID
                GpoType     = $GPO.GpoType
                #GpoCategory = $GPOEntry.GpoCategory
                #GpoSettings = $GPOEntry.GpoSettings
            }
            $SettingName = $Setting.Name -split ":"
            $CreateGPO['CreatedTime'] = $GPO.CreatedTime         # : 06.06.2020 18:03:36
            $CreateGPO['ModifiedTime'] = $GPO.ModifiedTime        # : 17.06.2020 16:08:10
            $CreateGPO['ReadTime'] = $GPO.ReadTime            # : 13.08.2020 10:15:37
            $CreateGPO['SecurityDescriptor'] = $GPO.SecurityDescriptor  # : SecurityDescriptor
            $CreateGPO['FilterDataAvailable'] = $GPO.FilterDataAvailable # : True

            $Name = $SettingName[1]
            #$Name = Format-ToTitleCase -Text $Setting.Name -RemoveWhiteSpace -RemoveChar ',', '-', "'", '\(', '\)', ':'
            $CreateGPO['Name'] = $Name # $Setting.Name
            #$CreateGPO['GPOSettingOrder'] = $Setting.GPOSettingOrder

            #foreach ($Property in ($Setting.Properties | Get-Member -MemberType Properties).Name) {

            ConvertTo-XMLNested -CreateGPO $CreateGPO -Setting $Setting -SkipNames $SkipNames #-Name $Name
            <#
        $Properties = $Setting.PSObject.Properties.Name | Where-Object { $_ -notin $SkipNames }
        foreach ($Property in $Properties) {
            If ($Property -eq 'Value') {
                if ($Setting.$Property) {
                    #$SubProperties = $Setting.$Property.PSObject.Properties.Name
                    if ($Setting.$Property.Name) {
                        $Name = $Setting.$Property.Name
                    } else {
                        $Name = 'Value'
                    }
                    if ($Setting.$Property.Number) {
                        $CreateGPO[$Name] = $Setting.$Property.Number
                    } elseif ($Setting.$Property.String) {
                        $CreateGPO[$Name] = $Setting.$Property.String
                    } else {
                        throw
                    }
                }
            } else {
                $Name = Format-CamelCaseToDisplayName -Text $Property #-RemoveWhiteSpace -RemoveChar ',', '-', "'", '\(', '\)', ':'
                if ($Setting.$Property -is [System.Xml.XmlElement]) {
                    $SubPropeties = $Setting.$Property.PSObject.Properties.Name | Where-Object { $_ -notin $SkipNames }



                } else {
                    $CreateGPO[$Name] = $Setting.$Property
                }
            }
        }
        #>
            $CreateGPO['Filters'] = $Setting.Filters
            $CreateGPO['Linked'] = $GPO.Linked
            $CreateGPO['LinksCount'] = $GPO.LinksCount
            $CreateGPO['Links'] = $GPO.Links
            [PSCustomObject] $CreateGPO
        }
    }
}