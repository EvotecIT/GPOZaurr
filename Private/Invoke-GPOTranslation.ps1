function Invoke-GPOTranslation {
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