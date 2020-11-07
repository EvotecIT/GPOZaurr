$GPOZaurrDuplicates = [ordered] @{
    Name       = 'Duplicate (CNF) Group Policies'
    Enabled    = $true
    Action     = $null
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
        New-HTMLTable -DataTable $Script:Reporting['GPODuplicates']['Data'] -Filtering
    }
}