$GPOZaurrPermissionsRoot = [ordered] @{
    Name       = 'Group Policies Root Permissions'
    Enabled    = $true
    Action     = $null
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
        New-HTMLTable -DataTable $Script:GPOConfiguration['GPOPermissionsRoot']['Data'] -Filtering
    }
}