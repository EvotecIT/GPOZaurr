Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Invoke-GPOZaurrSupport -ComputerName 'AD1' -UserName 'przemyslaw.klys' -Type HTML
#$Support
# $Support.ComputerResults.GPO | select name, @{LABEL=”LinkOrder“;EXPRESSION={$_.link.linkorder}} | sort linkorder
