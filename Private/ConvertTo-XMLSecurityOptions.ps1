function ConvertTo-XMLSecurityOptions {
    <#
    .SYNOPSIS
    Converts Group Policy Object (GPO) data to XML security options.

    .DESCRIPTION
    This function converts GPO data to XML security options for further processing.

    .PARAMETER GPO
    Specifies the GPO object to convert.

    .PARAMETER SingleObject
    Indicates whether to convert a single GPO object.

    .EXAMPLE
    ConvertTo-XMLSecurityOptions -GPO $myGPO -SingleObject
    Converts a single GPO object to XML security options.

    .EXAMPLE
    ConvertTo-XMLSecurityOptions -GPO $myGPO
    Converts multiple GPO objects to XML security options.

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
        [Array] $CreateGPO['Settings'] = foreach ($Entry in $GPO.DataSet) {
            $Object = [ordered] @{}
            $Object['KeyName'] = $Entry.KeyName
            $Object['KeyDisplayName'] = $Entry.Display.Name
            $Object['KeyDisplayUnits'] = $Entry.Display.Units
            $Object['KeyDisplayBoolean'] = try { [bool]::Parse($Entry.Display.DisplayBoolean) } catch { $null };
            $Object['KeyDisplayString'] = $Entry.Display.DisplayString
            $Object['SystemAccessPolicyName'] = $Entry.SystemAccessPolicyName
            if ($Entry.SettingString) {
                $Object['KeyValue'] = $Entry.SettingString
            } else {
                $Object['KeyValue'] = $Entry.SettingNumber
            }
            [PSCustomObject] $Object
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Entry in $GPO.DataSet) {
            $CreateGPO = [ordered]@{
                DisplayName = $GPO.DisplayName
                DomainName  = $GPO.DomainName
                GUID        = $GPO.GUID
                GpoType     = $GPO.GpoType
                #GpoCategory = $GPOEntry.GpoCategory
                #GpoSettings = $GPOEntry.GpoSettings
            }
            $CreateGPO['KeyName'] = $Entry.KeyName
            $CreateGPO['KeyDisplayName'] = $Entry.Display.Name
            $CreateGPO['KeyDisplayUnits'] = $Entry.Display.Units
            $CreateGPO['KeyDisplayBoolean'] = try { [bool]::Parse($Entry.Display.DisplayBoolean) } catch { $null };
            $CreateGPO['KeyDisplayString'] = $Entry.Display.DisplayString
            $CreateGPO['SystemAccessPolicyName'] = $Entry.SystemAccessPolicyName
            if ($Entry.SettingString) {
                $CreateGPO['KeyValue'] = $Entry.SettingString
            } else {
                $CreateGPO['KeyValue'] = $Entry.SettingNumber
            }
            $CreateGPO['Linked'] = $GPO.Linked
            $CreateGPO['LinksCount'] = $GPO.LinksCount
            $CreateGPO['Links'] = $GPO.Links
            [PSCustomObject] $CreateGPO
        }
    }
}