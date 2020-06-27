function Get-XMLGPOTypes {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [System.Xml.XmlElement[]] $GPOOutput,
        [string] $Splitter = [System.Environment]::NewLine,
        [switch] $FullObjects
    )

    $Types = [ordered] @{
        User     = [System.Collections.Generic.List[string]]::new()
        Computer = [System.Collections.Generic.List[string]]::new()
        All      = $null
    }

    [Array] $TypesReturn = foreach ($Type in @('User', 'Computer')) {
        if ($GPOOutput.$Type.ExtensionData.Extension) {
            foreach ($ExtensionType in $GPOOutput.$Type.ExtensionData.Extension) {
                $GPOSettingType = ($ExtensionType.type -split ':')[1]
                # add to hashtable
                $Types["$Type"].Add($GPOSettingType)
                # add to array
                $GPOSettingType
            }
        }
    }
    $Types.Computer = $Types.Computer | Sort-Object -Unique
    $Types.User = $Types.User | Sort-Object -Unique
    $Types.All = $TypesReturn | Sort-Object -Unique
    $Types
}