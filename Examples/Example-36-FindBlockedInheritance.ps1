Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Get basic output DN, CanonicalName, BlockInheritance (True/False)
#$Objects = Get-GPOZaurrInheritance
#$Objects | Format-Table

# Get same output DN, CanonicalName, BlockInheritance (True/False) + Users/Computers + UsersCount/ComputerCount for those with Blocked Inheritance
# This is so you can have a list what machines are affected
$ExcludedOU = @(
    # Works on OU/
    'ad.evotec.xyz/ITR02/Test'
)

$Objects = Get-GPOZaurrInheritance -IncludeBlockedObjects -IncludeExcludedObjects -OnlyBlockedInheritance -Exclusions $ExcludedOU -IncludeGroupPoliciesForBlockedObjects
$Objects | Format-Table