$GPOZaurrFiles = [ordered] @{
    Name       = 'SYSVOL (NetLogon) Files List'
    Enabled    = $true
    Action     = $null
    Data       = $null
    Execute    = {
        Get-GPOZaurrFiles
    }
    Processing = {

    }
    Variables  = @{

    }
    Overview   = {

    }
    Solution   = {
        New-HTMLTable -DataTable $Script:GPOConfiguration['GPOFiles']['Data'] -Filtering
    }
}