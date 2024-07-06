function ConvertTo-XMLDriveMapSettings {
    <#
    .SYNOPSIS
    Converts a PowerShell custom object representing drive mapping settings into XML format.

    .DESCRIPTION
    This function takes a PowerShell custom object representing drive mapping settings and converts it into XML format for storage or transmission.

    .PARAMETER GPO
    The PowerShell custom object representing the drive mapping settings.

    .PARAMETER SingleObject
    Indicates whether to convert a single object or multiple objects.

    .EXAMPLE
    ConvertTo-XMLDriveMapSettings -GPO $driveMapSettingsObject -SingleObject

    Description:
    Converts the $driveMapSettingsObject into XML format for a single object.

    .EXAMPLE
    $driveMapSettings | ConvertTo-XMLDriveMapSettings -SingleObject

    Description:
    Converts multiple drive mapping settings in $driveMapSettings into XML format for each object.
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
        [Array] $CreateGPO['Settings'] = foreach ($Entry in $GPO.DataSet.Drive) {
            [PSCustomObject] @{
                Changed         = [DateTime] $Entry.changed
                #uid             = $Entry.uid
                GPOSettingOrder = $Entry.GPOSettingOrder
                Filter          = $Entry.Filter

                Name            = $Entry.Name
                Status          = $Entry.status
                Action          = $Script:Actions["$($Entry.Properties.action)"]
                ThisDrive       = $Entry.Properties.thisDrive
                AllDrives       = $Entry.Properties.allDrives
                UserName        = $Entry.Properties.userName
                Path            = $Entry.Properties.path
                Label           = $Entry.Properties.label
                Persistent      = if ($Entry.Properties.persistent -eq '1') { $true } elseif ($Entry.Properties.persistent -eq '0') { $false } else { $Entry.Properties.persistent };
                UseLetter       = if ($Entry.Properties.useLetter -eq '1') { $true } elseif ($Entry.Properties.useLetter -eq '0') { $false } else { $Entry.Properties.useLetter };
                Letter          = $Entry.Properties.letter
            }
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Entry in $GPO.DataSet.Drive) {
            $CreateGPO = [ordered]@{
                DisplayName     = $GPO.DisplayName
                DomainName      = $GPO.DomainName
                GUID            = $GPO.GUID
                GpoType         = $GPO.GpoType
                #GpoCategory = $GPOEntry.GpoCategory
                #GpoSettings = $GPOEntry.GpoSettings
                Changed         = [DateTime] $Entry.changed
                #uid             = $Entry.uid
                GPOSettingOrder = $Entry.GPOSettingOrder
                Filter          = $Entry.Filter

                Name            = $Entry.Name
                Status          = $Entry.status
                Action          = $Script:Actions["$($Entry.Properties.action)"]
                ThisDrive       = $Entry.Properties.thisDrive
                AllDrives       = $Entry.Properties.allDrives
                UserName        = $Entry.Properties.userName
                Path            = $Entry.Properties.path
                Label           = $Entry.Properties.label
                Persistent      = if ($Entry.Properties.persistent -eq '1') { $true } elseif ($Entry.Properties.persistent -eq '0') { $false } else { $Entry.Properties.persistent };
                UseLetter       = if ($Entry.Properties.useLetter -eq '1') { $true } elseif ($Entry.Properties.useLetter -eq '0') { $false } else { $Entry.Properties.useLetter };
                Letter          = $Entry.Properties.letter
            }
            $CreateGPO['Linked'] = $GPO.Linked
            $CreateGPO['LinksCount'] = $GPO.LinksCount
            $CreateGPO['Links'] = $GPO.Links
            [PSCustomObject] $CreateGPO
        }
    }
}