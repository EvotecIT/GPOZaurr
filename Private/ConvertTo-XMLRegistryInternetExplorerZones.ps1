function ConvertTo-XMLRegistryInternetExplorerZones {
    <#
    .SYNOPSIS
    Converts registry settings related to Internet Explorer security zones into XML format.

    .DESCRIPTION
    This function converts registry settings from a Group Policy Object (GPO) related to Internet Explorer security zones into XML format. It extracts relevant information such as display name, domain name, GUID, GPO type, configuration, policy type, and security zone based on the registry settings provided.

    .PARAMETER GPO
    Specifies the Group Policy Object (GPO) containing the registry settings to be converted.

    .EXAMPLE
    ConvertTo-XMLRegistryInternetExplorerZones -GPO $GPO
    Converts the registry settings from the specified Group Policy Object ($GPO) related to Internet Explorer security zones into XML format.

    #>
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO
    )
    foreach ($Registry in $GPO.Settings) {
        $Keys = @(
            'Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\'
            'Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\EscDomains\'
        )
        $Found = $false
        foreach ($Key in $Keys) {
            if ($Registry.Key -like "$Key*") {
                $Found = $true
            }
        }
        if ($Found -eq $false) {
            continue
        }
        # https://support.microsoft.com/en-us/help/182569/internet-explorer-security-zones-registry-entries-for-advanced-users
        if ($Registry.Key -like 'Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\*') {
            $CreateGPO = [ordered]@{
                DisplayName = $GPO.DisplayName
                DomainName  = $GPO.DomainName
                GUID        = $GPO.GUID
                GpoType     = $GPO.GpoType
                #GpoCategory = $GPOEntry.GpoCategory
                #GpoSettings = $GPOEntry.GpoSettings
            }
            $CreateGPO['Disabled'] = $Registry.Disabled
            if ($Registry.Key -like '*EscDomains*') {
                $CreateGPO['Configuration'] = 'Enhanced Security Configuration (ESC)'
            } else {
                $CreateGPO['Configuration'] = 'Domains'
            }
            if ($Registry.Hive -eq 'HKEY_CURRENT_USER') {
                $CreateGPO['Type'] = 'User Policy'
            } elseif ($Registry.Hive -eq 'HKEY_LOCAL_MACHINE') {
                $CreateGPO['Type'] = 'Computer Policy'
            } else {
                $CreateGPO['Type'] = $Registry.Hive
            }
            if ($Registry.Value -eq '00000000') {
                $CreateGPO['Zone'] = 'My Computer (0)'
            } elseif ($Registry.Value -eq '00000001') {
                $CreateGPO['Zone'] = 'Local Intranet Zone (1)'
            } elseif ($Registry.Value -eq '00000002') {
                $CreateGPO['Zone'] = 'Trusted Sites Zone (2)'
            } elseif ($Registry.Value -eq '00000003') {
                $CreateGPO['Zone'] = 'Internet Zone (3)'
            } elseif ($Registry.Value -eq '00000004') {
                $CreateGPO['Zone'] = 'Restricted Sites Zone (4)'
            } else {
                $CreateGPO['Zone'] = $Registry.Value
            }
            [string] $FullKey = foreach ($Key in $Keys) {
                if ($Registry.Key -like "$Key*") {
                    $Registry.Key.Replace($Key, '')
                }
            }
            $DomainSplit = $FullKey.Split('\')
            $Reversed = for ($i = $DomainSplit.Count - 1; $i -ge 0; $i--) {
                $DomainSplit[$i]
            }
            if ($Registry.Name -eq '*') {
                $CreateGPO['DomainZone'] = $Reversed -join '.'
            } else {
                $CreateGPO['DomainZone'] = -join ($Registry.Name, '://', ($Reversed -join '.'))
            }
            $CreateGPO['Linked'] = $GPO.Linked
            $CreateGPO['LinksCount'] = $GPO.LinksCount
            $CreateGPO['Links'] = $GPO.Links
            [PSCustomObject] $CreateGPO
        }
    }
}