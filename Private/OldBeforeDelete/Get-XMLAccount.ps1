function Get-XMLAccount {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [System.Xml.XmlElement[]] $GPOOutput,
        [string] $Splitter = [System.Environment]::NewLine,
        [switch] $FullObjects
    )
    $LinksInformation = Get-LinksFromXML -GPOOutput $GPOOutput -Splitter $Splitter -FullObjects:$FullObjects
    foreach ($Type in @('User', 'Computer')) {
        if ($GPOOutput.$Type.ExtensionData.Extension) {
            foreach ($ExtensionType in $GPOOutput.$Type.ExtensionData.Extension) {
                foreach ($Key in $ExtensionType.Account) {
                    [PSCustomObject] @{
                        DisplayName    = $GPO.DisplayName
                        DomainName     = $GPO.DomainName
                        GUID           = $GPO.Guid
                        Linked         = $LinksInformation.Linked
                        LinksCount     = $LinksInformation.LinksCount
                        Links          = $LinksInformation.Links
                        GpoType        = $Type
                        Name           = $Key.Name
                        Type           = $Key.Type
                        SettingNumber  = $Key.SettingNumber
                        SettingBoolean = if ($Key.SettingBoolean -eq 'true') { $true } elseif ($Key.SettingBoolean -eq 'false') { $false } else { $null }
                    }
                }
            }
        }
    }
}

