$GPOZaurrPermissionsRoot = [ordered] @{
    Name       = 'Group Policies Root Permissions'
    Enabled    = $true
    Data       = $null
    Execute    = {
        Get-GPOZaurrPermissionRoot -SkipNames
    }
    Processing = {

    }
    Variables  = @{

    }
    Overview   = {

    }
    Solution   = {
        New-HTMLTable -DataTable $GPOZaurrPermissionsRoot['Data'] -Filtering
    }
}