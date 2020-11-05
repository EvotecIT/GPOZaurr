$GPOZaurrFiles = [ordered] @{
    Name       = 'GPO Permissions Consistency'
    Enabled    = $true
    Data       = $null
    Execute    = {
        $GPOFiles = Get-GPOZaurrFiles
     }
    Processing = {

    }
    Variables  = @{

    }
    Overview   = {

    }
    Solution   = {
        New-HTMLTable -DataTable $GPOFiles -Filtering
    }
}