function ConvertTo-XMLRegistryAutologonOnReport {
    <#
    .SYNOPSIS
    Converts Group Policy Object (GPO) settings related to Autologon into an XML report.

    .DESCRIPTION
    This function takes a GPO object as input and extracts Autologon related settings to generate an XML report.

    .PARAMETER GPO
    Specifies the GPO object containing Autologon settings.

    .EXAMPLE
    $GPO = [PSCustomObject]@{
        DisplayName = "Autologon GPO"
        DomainName = "example.com"
        GUID = "12345678-1234-1234-1234-1234567890AB"
        GpoType = "Security"
        Settings = @(
            [PSCustomObject]@{
                Key = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                Name = "AutoAdminLogon"
                Value = $true
                Changed = (Get-Date)
            }
        )
        Linked = $true
        LinksCount = 1
        Links = "area1.local"
    }
    ConvertTo-XMLRegistryAutologonOnReport -GPO $GPO
    #>
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO
    )
    $CreateGPO = [ordered]@{
        DisplayName                  = $GPO.DisplayName
        DomainName                   = $GPO.DomainName
        GUID                         = $GPO.GUID
        GpoType                      = $GPO.GpoType
        #GpoCategory = $GPOEntry.GpoCategory
        #GpoSettings = $GPOEntry.GpoSettings
        AutoAdminLogon               = $null
        DefaultDomainName            = $null
        DefaultUserName              = $null
        DefaultPassword              = $null
        DateChangedAutoAdminLogon    = $null
        DateChangedDefaultDomainName = $null
        DateChangedDefaultUserName   = $null
        DateChangedDefaultPassword   = $null
    }
    foreach ($Registry in $GPO.Settings) {
        if ($Registry.Key -eq 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon') {
            if ($Registry.Name -eq 'AutoAdminLogon') {
                $CreateGPO['AutoAdminLogon'] = [bool] $Registry.value
                $CreateGPO['DateChangedAutoAdminLogon'] = [DateTime] $Registry.changed
            } elseif ($Registry.Name -eq 'DefaultDomainName') {
                $CreateGPO['DefaultDomainName'] = $Registry.value
                $CreateGPO['DateChangedDefaultDomainName'] = [DateTime] $Registry.changed
            } elseif ($Registry.Name -eq 'DefaultUserName') {
                $CreateGPO['DefaultUserName'] = $Registry.value
                $CreateGPO['DateChangedDefaultUserName'] = [DateTime] $Registry.changed
            } elseif ($Registry.Name -eq 'DefaultPassword') {
                $CreateGPO['DefaultPassword'] = $Registry.value
                $CreateGPO['DateChangedDefaultPassword'] = [DateTime] $Registry.changed
            }
        }
    }
    if ($null -ne $CreateGPO['AutoAdminLogon'] -or
        $null -ne $CreateGPO['DefaultDomainName'] -or
        $null -ne $CreateGPO['DefaultUserName'] -or
        $null -ne $CreateGPO['DefaultPassword']
    ) {
        $CreateGPO['Linked'] = $GPO.Linked        #: True
        $CreateGPO['LinksCount'] = $GPO.LinksCount    #: 1
        $CreateGPO['Links'] = $GPO.Links         #: area1.local
        [PSCustomObject] $CreateGPO
    }
}