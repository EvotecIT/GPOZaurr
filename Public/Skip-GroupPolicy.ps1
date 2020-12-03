function Skip-GroupPolicy {
    [cmdletBinding()]
    param(
        [ValidateSet('GPOList')][string] $Type,
        [string] $Name,
        [string] $DomaiName
    )
    @{
        Type       = 'Exclusion'
        ReportType = $Type
        Name       = $Name
        DomainName = $DomaiName
    }
}