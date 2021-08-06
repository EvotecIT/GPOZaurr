Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Remove-GPOZaurrLinkEmptyOU -Verbose -LimitProcessing 3 -WhatIf

$Exclude = @(
    "OU=Groups,OU=Production,DC=ad,DC=evotec,DC=pl"
    "OU=Test \, OU,OU=ITR02,DC=ad,DC=evotec,DC=xyz"
)

Remove-GPOZaurrLinkEmptyOU -Verbose -LimitProcessing 3 -WhatIf -ExcludeOrganizationalUnit $Exclude