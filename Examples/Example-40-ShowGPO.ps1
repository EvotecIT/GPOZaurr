Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Verbose -Type GPOOrphans, GPOConsistency, GPOList, GPOPermissionsRoot
#Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Verbose -Type GPOOrphans, GPOConsistency, GPOList, GPOPermissionsRoot, NetLogon, GPOFiles
Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Verbose -Type GPOConsistency
#Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Verbose -Type GPOOrphans, GPOConsistency
#Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Verbose -Type GPOList
#Optimize-HTML -File 'C:\Support\GitHub\GpoZaurr\Examples\Reports\GPOZaurr.html' -OutputFile 'C:\Support\GitHub\GpoZaurr\Examples\Reports\GPOZaurr-Minified.html'
