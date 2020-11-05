$GPOZaurrAnalysis = [ordered] @{
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
        foreach ($Key in $GPOContent.Keys) {
            New-HTMLTab -Name $Key {
                New-HTMLTable -DataTable $GPOContent[$Key] -Filtering -Title $Key
            }
        }
    }
}