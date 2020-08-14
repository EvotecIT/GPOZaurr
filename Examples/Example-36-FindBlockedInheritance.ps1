Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Get basic output DN, CanonicalName, BlockInheritance (True/False)
#$Objects = Get-GPOZaurrInheritance
#$Objects | Format-Table

# Get same output DN, CanonicalName, BlockInheritance (True/False) + Users/Computers + UsersCount/ComputerCount for those with Blocked Inhertiance
# This is so you can have a list what machines are affected
$Objects = Get-GPOZaurrInheritance -IncludeBlockedObjects -OnlyBlockedInheritance
$Objects | Format-Table