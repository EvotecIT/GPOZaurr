function ConvertTo-Policies {
    [cmdletBinding()]
    param(
        [Array] $GPOList
    )
    foreach ($GPOEntry in $GPOList) {
        $CreateGPO = [ordered]@{
            DisplayName        = $GPOEntry.DisplayName   #: WO_SEC_NTLM_Auth_Level
            DomainName         = $GPOEntry.DomainName    #: area1.local
            GUID               = $GPOEntry.GUID          #: 364B095E-C7BF-4CC1-9BFA-393BD38975E5
            GpoType            = $GPOEntry.GpoType       #: Computer
            GpoCategory        = $GPOEntry.GpoCategory   #: SecuritySettings
            GpoSettings        = $GPOEntry.GpoSettings   #: SecurityOptions
            PolicyName         = $GPOEntry.Name
            PolicyState        = $GPOEntry.State
            PolicyCategory     = $GPOEntry.Category
            PolicySupported    = $GPOEntry.Supported
            PolicyExplain      = $GPOEntry.Explain
            PolicyText         = $GPOEntry.Text
            PolicyCheckBox     = $GPOEntry.CheckBox
            PolicyDropDownList = $GPOEntry.DropDownList
            PolicyEditText     = $GPOEntry.EditText
        }
        $CreateGPO['Linked'] = $GPOEntry.Linked        #: True
        $CreateGPO['LinksCount'] = $GPOEntry.LinksCount    #: 1
        $CreateGPO['Links'] = $GPOEntry.Links         #: area1.local
        [PSCustomObject] $CreateGPO

    }
}

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