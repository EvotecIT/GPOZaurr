Clear-Host
Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Report = Get-GPOZaurrLinkSummary -Report OneLink
$Report | Format-Table
$AffectedGPOs = foreach ($GPO in $Report) {
    if ($GPO.Level1 -gt 1) {
        $GPO
    }
}

$AffectedGPOs | Format-Table *