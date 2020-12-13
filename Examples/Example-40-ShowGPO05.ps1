Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$GPOS = Get-GPOZaurr -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\Empty' -ExcludeGroupPolicies @(
    Skip-GroupPolicy -Name 'de14_usr_std'
    Skip-GroupPolicy -Name 'de14_usr_std' -DomaiName 'ad.evotec.xyz'
)
$GPOS | Format-Table -AutoSize *