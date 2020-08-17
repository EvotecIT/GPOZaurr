function ConvertTo-XMLGenericPublicKey {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [string[]] $Category
    )

    $SkipNames = ('Name', 'LocalName', 'NamespaceURI', 'Prefix', 'NodeType', 'ParentNode', 'OwnerDocument', 'IsEmpty', 'Attributes', 'HasAttributes', 'SchemaInfo', 'InnerXml', 'InnerText', 'NextSibling', 'PreviousSibling', 'ChildNodes', 'FirstChild', 'LastChild', 'HasChildNodes', 'IsReadOnly', 'OuterXml', 'BaseURI', 'PreviousText')
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