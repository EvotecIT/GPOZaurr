function ConvertTo-XMLPolicies {
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