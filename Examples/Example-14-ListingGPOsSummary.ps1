Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Summary = Get-GPOZaurrLink -Summary
$Summary | Format-Table -AutoSize *

$OneGPO = $Summary | Where-Object { $_.DisplayName -eq 'ALL | Enable RDP' }
$OneGPO.Links
$OneGPO.LinksObjects | Format-Table *