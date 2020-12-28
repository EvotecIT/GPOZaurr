Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Types = @(
    @{ Name = 'GPOOwners'; Path = "$PSScriptRoot\Reports\GPOOwners.html" }
    @{ Name = 'GPOConsistency'; Path = "$PSScriptRoot\Reports\GPOConsistency.html" }
    @{ Name = 'GPODuplicates'; Path = "$PSScriptRoot\Reports\GPODuplicates.html" }
    @{ Name = 'GPOList'; Path = "$PSScriptRoot\Reports\GPOList.html" }
    @{ Name = 'GPOBroken'; Path = "$PSScriptRoot\Reports\GPOOrphans.html" }
    @{ Name = 'GPOPassword'; Path = "$PSScriptRoot\Reports\GPOPassword.html" }
    @{ Name = 'NetLogonPermissions'; Path = "$PSScriptRoot\Reports\NetLogonPermissions.html" }
)

foreach ($Type in $Types) {
    Invoke-GPOZaurr -FilePath $Type.Path -Type $Type.Name -HideHTML
}