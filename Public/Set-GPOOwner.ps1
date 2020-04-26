function Set-GPOOwner {
    [cmdletBinding()]
    param(
        [validateset('Administrative', 'Default')][string] $Type = 'Default',
        [string] $Principal
    )
    if ($Type -eq 'Default') {
        if ($Principal) {
            @{
                Action    = 'Owner'
                Type      = 'Default'
                Principal = $Principal
            }
        }
    } elseif ($Type -eq 'Administrative') {
        @{
            Action    = 'Owner'
            Type      = 'Administrative'
            Principal = ''
        }
    }
}