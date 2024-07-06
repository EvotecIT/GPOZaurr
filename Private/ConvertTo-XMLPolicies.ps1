function ConvertTo-XMLPolicies {
    <#
    .SYNOPSIS
    Converts Group Policy Object (GPO) data to XML format.

    .DESCRIPTION
    This function converts the provided GPO data into XML format for easier processing and analysis.

    .PARAMETER GPO
    Specifies the GPO object containing the data to be converted.

    .PARAMETER SingleObject
    Indicates whether to convert a single GPO object or multiple GPO objects.

    .EXAMPLE
    ConvertTo-XMLPolicies -GPO $myGPO -SingleObject
    Converts a single GPO object $myGPO to XML format.

    .EXAMPLE
    ConvertTo-XMLPolicies -GPO $GPOList
    Converts multiple GPO objects in $GPOList to XML format.

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
        [Array] $CreateGPO['Settings'] = foreach ($Policy in $GPO.DataSet) {
            [PSCustomObject] @{
                PolicyName         = $Policy.Name
                PolicyState        = $Policy.State
                PolicyCategory     = $Policy.Category
                PolicySupported    = $Policy.Supported
                PolicyExplain      = $Policy.Explain
                PolicyText         = $Policy.Text
                PolicyCheckBox     = $Policy.CheckBox
                PolicyDropDownList = $Policy.DropDownList
                PolicyEditText     = $Policy.EditText
            }
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Policy in $GPO.DataSet) {
            $CreateGPO = [ordered]@{
                DisplayName        = $GPO.DisplayName
                DomainName         = $GPO.DomainName
                GUID               = $GPO.GUID
                GpoType            = $GPO.GpoType
                #GpoCategory = $GPOEntry.GpoCategory
                #GpoSettings = $GPOEntry.GpoSettings
                PolicyName         = $Policy.Name
                PolicyState        = $Policy.State
                PolicyCategory     = $Policy.Category
                PolicySupported    = $Policy.Supported
                PolicyExplain      = $Policy.Explain
                PolicyText         = $Policy.Text
                PolicyCheckBox     = $Policy.CheckBox
                PolicyDropDownList = $Policy.DropDownList
                PolicyEditText     = $Policy.EditText
            }
            $CreateGPO['Linked'] = $GPO.Linked
            $CreateGPO['LinksCount'] = $GPO.LinksCount
            $CreateGPO['Links'] = $GPO.Links
            [PSCustomObject] $CreateGPO
        }
    }
}