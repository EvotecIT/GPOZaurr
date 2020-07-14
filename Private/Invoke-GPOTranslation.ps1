function Invoke-GPOTranslationOld {
    [cmdletBinding()]
    param(
        [System.Collections.IDictionary] $InputData,
        [string] $Report,
        [string] $Category,
        [string] $Settings
    )
    if ($Category -and $Settings -and $InputData) {
        if ($Script:GPODitionary[$Report]['Code']) {
            $Script:GPOList = $InputData.$Category.$Settings
            return & $Script:GPODitionary[$Report]['Code']
        }
    }
}

function Invoke-GPOTranslation {
    [cmdletBinding()]
    param(
        [Array] $InputData,
        [string] $Report,
        [string] $Category,
        [string] $Settings
    )
    if ($Category -and $Settings -and $InputData) {
        if ($Script:GPODitionary[$Report]['Code']) {
            $Script:GPOList = $InputData
            return & $Script:GPODitionary[$Report]['Code']
        }
    }
}
