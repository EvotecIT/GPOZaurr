Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

#Invoke-GPOZaurr -OutputType Excel, Object, HTML -Open | Format-Table
$Output = Invoke-GPOZaurr -GPOPath $Env:USERPROFILE\Desktop\GPOExport -NoTranslation #| Format-Table
#$Output.Count



<# 4073 files - 212MB / no translation

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 51
Milliseconds      : 756
Ticks             : 517566534
TotalDays         : 0,000599035340277778
TotalHours        : 0,0143768481666667
TotalMinutes      : 0,86261089
TotalSeconds      : 51,7566534
TotalMilliseconds : 51756,6534
#>

<# 4073 files - 212MB / no translation / But with 2 diff types ($OutputByCategory / $OutputByGPO)
Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 53
Milliseconds      : 246
Ticks             : 532466109
TotalDays         : 0,00061628021875
TotalHours        : 0,01479072525
TotalMinutes      : 0,887443515
TotalSeconds      : 53,2466109
TotalMilliseconds : 53246,6109
#>