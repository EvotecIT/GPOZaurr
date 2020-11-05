$GPOZaurrPermissions = [ordered] @{
    Name       = 'GPO Permissions'
    Enabled    = $true
    Data       = $null
    Execute    = {
        $GPOPermissions = Get-GPOZaurrPermission -Type All -IncludePermissionType GpoEditDeleteModifySecurity, GpoEdit, GpoCustom -IncludeOwner

    }
    Processing = {

    }
    Variables  = @{

    }
    Overview   = {

    }
    Solution   = {

    }
}