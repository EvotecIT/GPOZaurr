function Get-LinksFromXML {
    [cmdletBinding()]
    param(
        [System.Xml.XmlElement[]] $GPOOutput,
        [string] $Splitter,
        [switch] $FullObjects
    )
    $Links = [ordered] @{
        Linked     = $null
        LinksCount = $null
        Links      = $null
    }
    if ($GPOOutput.LinksTo) {
        $Links.Linked = $true
        $Links.LinksCount = ([Array] $GPOOutput.LinksTo).Count
        $Links.Links = foreach ($Link in $GPOOutput.LinksTo) {
            if ($FullObjects) {
                [PSCustomObject] @{
                    Path       = $Link.SOMPath
                    Enabled    = if ($Link.Enabled -eq 'true') { $true } else { $false }
                    NoOverride = if ($Link.NoOverride -eq 'true') { $true } else { $false }
                }
            } else {
                if ($Link.Enabled) {
                    $Link.SOMPath
                }
            }
        }
        if ($Splitter) {
            $Links.Links = $Links.Links -join $Splitter
        }
    } else {
        $Links.Linked = $false
        $Links.LinksCount = 0
        $Links.Links = $null
    }
    [PSCustomObject] $Links
}