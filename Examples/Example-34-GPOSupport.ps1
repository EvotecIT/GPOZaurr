Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force
<#
[xml] $Test1 = -join ('<Details>', $Support.ComputerResults.EventsByID.'5312'.GPOinfoList, '</Details>')
[xml] $Test2 = -join ('<Details>', $Support.ComputerResults.EventsByID.'5313'.GPOinfoList, '</Details>')
$Test1
$Test2
#>

#$Support = Invoke-GPOZaurrSupport -ComputerName 'AD2' -UserName 'przemyslaw.klys' -Type Object


Invoke-GPOZaurrSupport -ComputerName 'AD2' -UserName 'przemyslaw.klys' -Type HTML
#$Support
# $Support.ComputerResults.GPO | select name, @{LABEL=”LinkOrder“;EXPRESSION={$_.link.linkorder}} | sort linkorder
