Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Use Save-GPOZaurrFiles -GPOPath $ENV:USERPROFILE\Desktop\GPOExport

$OutputTranslation = Invoke-GPOZaurr -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPOExport'
$OutputTranslation | Format-Table
$Output = Invoke-GPOZaurr -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPOExport' -NoTranslation
$Output | Format-Table *

#$Output.LugsSettings.LocalUsersAndGroups | Format-List *

$GPOEntry = $Output.LugsSettings.LocalUsersAndGroups[0]

$CreateGPO = @{}
foreach ($User in $GPOEntry.User) {
    # $User | Format-Table
    # $User.Properties | Format-Table
}


foreach ($Group in $GPOEntry.Group) {
    #$Group | Format-Table
    $Group.Properties | Format-Table
    $Group.Properties.Members | Format-Table
}