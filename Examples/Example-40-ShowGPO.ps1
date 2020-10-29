#Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Verbose -Type NetLogon, GPOOrphans, GPOList, GPOConsistency

# Working conditions
#Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurrOrphans.html -Verbose -Type GPOOrphans
#Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurrEmptyUnlinked.html -Verbose -Type GPOList
#Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurrEmptyUnlinked.html -Verbose -Type GPOConsistency
#Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Verbose -Type NetLogon

#Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Verbose -Type GPOOwners

#Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Verbose -Type GPOPermissionsRoot

#Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Verbose -Type GPOOrphans, GPOConsistency, GPOList, GPOPermissionsRoot, NetLogon, GPOFiles
#Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Verbose -Type GPOConsistency
#Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Verbose -Type GPOOrphans, GPOConsistency
#Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Verbose -Type GPOList
#Optimize-HTML -File 'C:\Support\GitHub\GpoZaurr\Examples\Reports\GPOZaurr.html' -OutputFile 'C:\Support\GitHub\GpoZaurr\Examples\Reports\GPOZaurr-Minified.html'