﻿function ConvertTo-XMLWindowsFirewallSecurityRules {
    <#
    .SYNOPSIS
    Converts Windows Firewall security rules data to XML format.

    .DESCRIPTION
    This function converts Windows Firewall security rules data to XML format. It takes a GPO object as input and generates XML data representing the security rules.

    .PARAMETER GPO
    Specifies the Group Policy Object (GPO) containing the security rules data.

    .PARAMETER SingleObject
    Indicates whether to convert a single GPO object or multiple security rules.

    .EXAMPLE
    $GPO = Get-GPO -Name "FirewallRules"
    ConvertTo-XMLWindowsFirewallSecurityRules -GPO $GPO -SingleObject
    Converts the security rules data from the GPO "FirewallRules" to XML format for a single GPO object.

    .EXAMPLE
    $GPOs = Get-GPO -All
    ConvertTo-XMLWindowsFirewallSecurityRules -GPO $GPOs -SingleObject:$false
    Converts the security rules data from all GPOs to XML format for multiple security rules.

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
        [Array] $CreateGPO['Settings'] = foreach ($Rule in $GPO.DataSet) {
            [PSCustomObject] @{
                Version     = $Rule.Version
                Name        = $Rule.Name
                Action      = $Rule.Action
                Enabled     = if ($Rule.Active -eq 'true') { $true } else { $false }
                Auth1Set    = $Rule.Auth1Set
                Auth2Set    = $Rule.Auth2Set
                Crypto2Set  = $Rule.Crypto2Set
                Description = $Rule.Desc
            }
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Rule in $GPO.DataSet) {
            [PSCustomObject]@{
                DisplayName = $GPO.DisplayName
                DomainName  = $GPO.DomainName
                GUID        = $GPO.GUID
                GpoType     = $GPO.GpoType
                Version     = $Rule.Version
                Name        = $Rule.Name
                Action      = $Rule.Action
                Enabled     = if ($Rule.Active -eq 'true') { $true } else { $false }
                Auth1Set    = $Rule.Auth1Set
                Auth2Set    = $Rule.Auth2Set
                Crypto2Set  = $Rule.Crypto2Set
                Description = $Rule.Desc
                Linked      = $GPO.Linked
                LinksCount  = $GPO.LinksCount
                Links       = $GPO.Links
            }
        }
    }
}

<#
Version    : 2.30
Action     : Boundary
Name       : TeST Aut
Auth1Set   : {E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE3}
Auth2Set   : {E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE4}
Crypto2Set : {E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE2}
Desc       :
Active     : true

Version    : 2.30
Action     : Boundary
Name       : CA TEST
Auth1Set   : {0E3A2DDC-F31B-42B5-BEAC-890752F9C0BB}
Auth2Set   : EmptySet
Crypto2Set : {E5A5D32A-4BCE-4e4d-B07F-4AB1BA7E5FE2}
Desc       :
Active     : true
#>