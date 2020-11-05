$GPOZaurrPassword = [ordered] @{
    Name       = 'Group Policy Passwords'
    Enabled    = $true
    Data       = $null
    Execute    = {
        Get-GPOZaurrPassword
    }
    Processing = {

    }
    Variables  = @{

    }
    Overview   = {

    }
    Solution   = {
        New-HTMLTable -DataTable $GPOZaurrPassword['Data'] -Filtering
    }
}