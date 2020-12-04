function Skip-GroupPolicy {
    [cmdletBinding()]
    param(
        [ValidateSet('GPOList')][string] $Type,
        [string] $Name,
        [string] $DomaiName
    )
    if ($Type) {
        [PSCustomObject] @{
            Type       = $Type
            Name       = $Name
            DomainName = $DomaiName
        }
    } else {
        [PSCustomObject] @{
            Name       = $Name
            DomainName = $DomaiName
        }
    }
}