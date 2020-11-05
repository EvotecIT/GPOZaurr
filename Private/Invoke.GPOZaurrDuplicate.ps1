$GPOZaurrDuplicates = [ordered] @{
    Name       = 'Duplicate (CNF) Group Policies'
    Enabled    = $true
    Data       = $null
    Execute    = {
        Get-GPOZaurrDuplicateObject
    }
    Processing = {

    }
    Variables  = @{

    }
    Overview   = {

    }
    Solution   = {
        New-HTMLTable -DataTable $GPOZaurrDuplicates['Data'] -Filtering
    }
}