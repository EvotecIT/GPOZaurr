function ConvertTo-XMLGenericSecuritySettings {
    <#
    .SYNOPSIS
    Converts Generic Security Settings to XML format.

    .DESCRIPTION
    This function converts Generic Security Settings to XML format for further processing.

    .PARAMETER GPO
    Specifies the Group Policy Object (GPO) to convert.

    .PARAMETER Category
    Specifies the category of settings to convert.

    .EXAMPLE
    ConvertTo-XMLGenericSecuritySettings -GPO $GPOObject -Category 'Security'

    Description:
    Converts the security settings of the specified GPO object to XML format.

    .EXAMPLE
    ConvertTo-XMLGenericSecuritySettings -GPO $GPOObject -Category 'Network'

    Description:
    Converts the network settings of the specified GPO object to XML format.
    #>
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [string[]] $Category
    )
    $SkipNames = ('Name', 'LocalName', 'NamespaceURI', 'Prefix', 'NodeType', 'ParentNode', 'OwnerDocument', 'IsEmpty', 'Attributes', 'HasAttributes', 'SchemaInfo', 'InnerXml', 'InnerText', 'NextSibling', 'PreviousSibling', 'Value', 'ChildNodes', 'FirstChild', 'LastChild', 'HasChildNodes', 'IsReadOnly', 'OuterXml', 'BaseURI', 'PreviousText')
    #$UsedNames = [System.Collections.Generic.List[string]]::new()
    [Array] $Settings = foreach ($Cat in $Category) {
        $GPO.DataSet | Where-Object { $null -ne $_.$Cat }
    }

    if ($Settings.Count -gt 0) {
        foreach ($Cat in $Category) {
            foreach ($Setting in $Settings.$Cat) {
                $CreateGPO = [ordered]@{
                    DisplayName = $GPO.DisplayName
                    DomainName  = $GPO.DomainName
                    GUID        = $GPO.GUID
                    GpoType     = $GPO.GpoType
                    #GpoCategory = $GPOEntry.GpoCategory
                    #GpoSettings = $GPOEntry.GpoSettings
                }
                #$Name = Format-ToTitleCase -Text $Setting.Name -RemoveWhiteSpace -RemoveChar ',', '-', "'", '\(', '\)', ':'
                $CreateGPO['Name'] = $Setting.Name
                $CreateGPO['GPOSettingOrder'] = $Setting.GPOSettingOrder
                #foreach ($Property in ($Setting.Properties | Get-Member -MemberType Properties).Name) {

                $Properties = $Setting.Properties.PSObject.Properties.Name | Where-Object { $_ -notin $SkipNames }
                foreach ($Property in $Properties) {

                    $Name = Format-CamelCaseToDisplayName -Text $Property #-RemoveWhiteSpace -RemoveChar ',', '-', "'", '\(', '\)', ':'
                    $CreateGPO[$Name] = $Setting.Properties.$Property
                }
                $CreateGPO['Filters'] = $Setting.Filters

                $CreateGPO['Linked'] = $GPO.Linked
                $CreateGPO['LinksCount'] = $GPO.LinksCount
                $CreateGPO['Links'] = $GPO.Links
                [PSCustomObject] $CreateGPO
            }
        }
    }

}