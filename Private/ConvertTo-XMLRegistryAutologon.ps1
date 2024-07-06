function ConvertTo-XMLRegistryAutologon {
    <#
    .SYNOPSIS
    Converts a Group Policy Object (GPO) to an XML format for Registry Autologon settings.

    .DESCRIPTION
    This function takes a GPO object as input and extracts relevant Registry Autologon settings to create an XML representation.

    .PARAMETER GPO
    Specifies the Group Policy Object (GPO) to be converted to XML format for Registry Autologon settings.

    .EXAMPLE
    $GPO = [PSCustomObject]@{
        DisplayName = "Autologon GPO"
        DomainName = "example.com"
        GUID = "12345678-1234-5678-1234-567812345678"
        GpoType = "Registry"
        DataSet = [PSCustomObject]@{
            Registry = @(
                [PSCustomObject]@{
                    Properties = [PSCustomObject]@{
                        Key = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                        Name = "AutoAdminLogon"
                        Value = $true
                        Changed = Get-Date
                    }
                },
                [PSCustomObject]@{
                    Properties = [PSCustomObject]@{
                        Key = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                        Name = "DefaultDomainName"
                        Value = "example.com"
                        Changed = Get-Date
                    }
                },
                [PSCustomObject]@{
                    Properties = [PSCustomObject]@{
                        Key = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                        Name = "DefaultUserName"
                        Value = "user"
                        Changed = Get-Date
                    }
                },
                [PSCustomObject]@{
                    Properties = [PSCustomObject]@{
                        Key = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                        Name = "DefaultPassword"
                        Value = "password"
                        Changed = Get-Date
                    }
                }
            )
        }
    }
    ConvertTo-XMLRegistryAutologon -GPO $GPO
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
    foreach ($Registry in $GPO.DataSet.Registry) {
        if ($Registry.Properties.Key -eq 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon') {
            if ($Registry.Properties.Name -eq 'AutoAdminLogon') {
                $CreateGPO['AutoAdminLogon'] = [bool] $Registry.Properties.value
                $CreateGPO['DateChangedAutoAdminLogon'] = [DateTime] $Registry.changed
            } elseif ($Registry.Properties.Name -eq 'DefaultDomainName') {
                $CreateGPO['DefaultDomainName'] = $Registry.Properties.value
                $CreateGPO['DateChangedDefaultDomainName'] = [DateTime] $Registry.changed
            } elseif ($Registry.Properties.Name -eq 'DefaultUserName') {
                $CreateGPO['DefaultUserName'] = $Registry.Properties.value
                $CreateGPO['DateChangedDefaultUserName'] = [DateTime] $Registry.changed
            } elseif ($Registry.Properties.Name -eq 'DefaultPassword') {
                $CreateGPO['DefaultPassword'] = $Registry.Properties.value
                $CreateGPO['DateChangedDefaultPassword'] = [DateTime] $Registry.changed
            }
        }
    }
    if ($null -ne $CreateGPO['AutoAdminLogon'] -or
        $null -ne $CreateGPO['DefaultDomainName'] -or
        $null -ne $CreateGPO['DefaultUserName'] -or
        $null -ne $CreateGPO['DefaultPassword']
    ) {
        $CreateGPO['Linked'] = $GPOEntry.Linked
        $CreateGPO['LinksCount'] = $GPOEntry.LinksCount
        $CreateGPO['Links'] = $GPOEntry.Links
        [PSCustomObject] $CreateGPO
    }
}