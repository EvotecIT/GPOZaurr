Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Invoke-GPOZaurr -Online -Verbose -FilePath $PSScriptRoot\Reports\GPOZaurr.html -SplitReports