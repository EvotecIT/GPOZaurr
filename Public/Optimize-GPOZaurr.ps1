function Optimize-GPOZaurr {
    [cmdletBinding()]
    param(

    )

    $GPOS = Get-GPOZaurr -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    foreach ($GPO in $GPOS) {
        if ($GPO.UserSettingsAvailable -eq $false -and $GPO.ComputerSettingsAvailable -eq $false) {
            if ($GPO.Enabled -ne 'All setttings disabled') {
               # $GPO
            }
        } elseif ($GPO.UserSettingsAvailable -eq $false) {

        } elseif ($GPO.ComputerSettingsAvailable -eq $false) {

        }
    }
}