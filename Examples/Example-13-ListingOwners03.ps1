Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurrGPOOwners.html -Type GPOOwners -Online -Exclusions @(
    'EVOTEC\Domain Admins'
    'EVOTEC\przemyslaw.klys'
)