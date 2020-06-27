function Select-GPOTranslation {
    [cmdletbInding()]
    param(
        [Parameter(ValueFromPipeline)][System.Collections.IDictionary] $InputObject,
        [string] $Category,
        [string] $Settings
    )

    $Important = [ordered] @{}
    $AllProperties = Select-Properties -AllProperties -Objects $InputObject.$Category.$Settings
    $MissingProperties = $AllProperties | Where-Object { $_ -notin 'DisplayName', 'DomainName', 'GUID', 'Linked', 'LinksCount', 'Links', 'GPOType', 'GPOCategory', 'GPOSettings' }
    $Types = foreach ($Property in $MissingProperties) {
        ($InputObject.$Category.$Settings | Where-Object { $null -ne $_.$Property }).$Property | ForEach-Object {
            ($_ | Get-Member -MemberType Properties) | Where-Object { $_.Name -notin 'Length' }
        }
    }
    $Important['AllProperties'] = $AllProperties
    $Important['MissingProperties'] = $MissingProperties
    $Important['Types'] = $Types | Select-Object -Unique
    $Important['Data'] = $InputObject.$Category.$Settings
    $Important
}