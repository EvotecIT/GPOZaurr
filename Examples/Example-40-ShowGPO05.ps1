Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$GPOS = Get-GPOZaurr -ExcludeGroupPolicies {
    Skip-GroupPolicy -Name 'de14_usr_std'
    Skip-GroupPolicy -Name 'de14_usr_std' -DomaiName 'ad.evotec.xyz'
    Skip-GroupPolicy -Name 'All | Trusted Websites' #-DomaiName 'ad.evotec.xyz'
    '{D39BF08A-87BF-4662-BFA0-E56240EBD5A2}'
    'COMPUTERS | Enable Sets'
}
$GPOS | Format-Table -AutoSize *

$Output = Invoke-GPOZaurr -Type GPOList -Exclusions {
    Skip-GroupPolicy -Name 'All | Trusted Websites' -DomaiName 'ad.evotec.xyz'
    '{D39BF08A-87BF-4662-BFA0-E56240EBD5A2}'
    "104da6a7-c7d2-48da-b24b-8fa584f7b0b6"
    "{087b4f69-c541-429f-8dfd-0eb3ed133910}"
    'COMPUTERS | Enable Sets'
    '24194523-bb82-439c-a533-abf4f30fa2c4'
    '{31b2f340-016d-11d2-945f-00c04fb984f9 } '
} -PassThru

$Output.GPOList