Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Get-GPOZaurrUpdates -DateRange Last14Days -DateProperty WhenCreated, WhenChanged -Verbose -IncludeDomains 'ad.evotec.pl' | Format-List
Get-GPOZaurrUpdates -DateRange Last14Days -DateProperty WhenCreated -Verbose | Format-Table