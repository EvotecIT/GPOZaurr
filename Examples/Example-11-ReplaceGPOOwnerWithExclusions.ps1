Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$GPOs = Get-GPOZaurrOwner -IncludeSysvol -Verbose
$GPOs | Format-Table DisplayName, Status, Owner, OwnerSID, OwnerType, SysvolOwner, SysvolSID, SysvolType

#Set-GPOZaurrOwner -Type All -Verbose -LimitProcessing 2 -WhatIf -IncludeDomains 'ad.evotec.xyz'

Set-GPOZaurrOwner -Type All -Verbose -LimitProcessing 2 -WhatIf -IncludeDomains 'ad.evotec.xyz' -ApprovedOwner @(
    'EVOTEC\przemyslaw.klys'
)