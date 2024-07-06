function Get-LinksFromXML {
    <#
    .SYNOPSIS
    Retrieves links from XML data.

    .DESCRIPTION
    This function retrieves links from XML data provided as input. It processes the XML data to extract relevant information about the links.

    .PARAMETER GPOOutput
    Specifies the XML data containing information about the links.

    .PARAMETER Splitter
    Specifies the delimiter to use when joining multiple links.

    .PARAMETER FullObjects
    Indicates whether to return full objects with additional properties for each link.

    .EXAMPLE
    Get-LinksFromXML -GPOOutput $xmlData -Splitter ";" -FullObjects
    Retrieves links from the XML data $xmlData, separates them with a semicolon, and returns full objects for each link.

    .EXAMPLE
    Get-LinksFromXML -GPOOutput $xmlData -Splitter "/" 
    Retrieves links from the XML data $xmlData and joins them with a forward slash.

    #>
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