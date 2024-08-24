Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

#Save-GPOZaurrFiles -GPOPath $Env:USERPROFILE\Desktop\TestF

#Get-GPOZaurr -GPOPath "$Env:USERPROFILE\Desktop\TestF" | Sort-Object -Property DisplayName | Where-Object { $_.EMpty -eq $true } | Format-Table *



return
$GPO = Get-GPOZaurr -GPOName 'ALL | Allow use of biometrics'
$GPO | Format-List *

#$GPO.Count
#$GPO | Where-Object { $_.Empty -eq $true } | Format-Table *
#($GPO | Where-Object { $_.Empty -eq $true }).Count
#$GPO | Where-Object { $_.DisplayName -like "*TEST*" } | Format-Table *