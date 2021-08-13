Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$GPOS = Get-GPOZaurr -ExcludeGroupPolicies {
    Skip-GroupPolicy -Name 'de14_usr_std'
    Skip-GroupPolicy -Name 'de14_usr_std' -DomaiName 'ad.evotec.xyz'
    Skip-GroupPolicy -Name 'All | Trusted Websites' #-DomaiName 'ad.evotec.xyz'
    '{D39BF08A-87BF-4662-BFA0-E56240EBD5A2}'
    'COMPUTERS | Enable Sets'
}
$GPOS | Format-Table -AutoSize *

Invoke-GPOZaurr -Type GPOList -Exclusions {
    Skip-GroupPolicy -Name 'All | Trusted Websites' -DomaiName 'ad.evotec.xyz'
    '{D39BF08A-87BF-4662-BFA0-E56240EBD5A2}'
    'COMPUTERS | Enable Sets'
}