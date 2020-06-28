function Find-MissingProperties {
    [cmdletBinding()]
    param(
        [Array] $Objects,
        [string[]] $PossibleProperties
    )
    $AllProperties = Select-Properties -AllProperties -Objects $Objects
    $MissingProperties = $AllProperties | Where-Object { $_ -notin 'DisplayName', 'DomainName', 'GUID', 'Linked', 'LinksCount', 'Links', 'GPOType', 'GPOCategory', 'GPOSettings' }
    [Array] $ConsiderAdding = foreach ($Property in $MissingProperties) {
        if ($Property -notin $PossibleProperties) {
            $Property
        }
    }
    $ConsiderAdding
}