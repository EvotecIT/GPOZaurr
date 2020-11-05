$GPOZaurrPermissionsRoot = [ordered] @{
    Name       = 'GPO Permissions Consistency'
    Enabled    = $true
    Data       = $null
    Execute    = {
        $GPOPermissionsRoot = Get-GPOZaurrPermissionRoot -SkipNames
     }
    Processing = {

    }
    Variables  = @{

    }
    Overview   = {

    }
    Solution   = {
        New-HTMLTable -DataTable $GPOPermissionsRoot -Filtering
    }
}