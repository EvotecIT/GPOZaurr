$GPOZaurrPermissionsRoot = [ordered] @{
    Name       = 'GPO Permissions Consistency'
    Enabled    = $true
    Data       = $null
    Execute    = {  }
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