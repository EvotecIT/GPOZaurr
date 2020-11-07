$GPOZaurrAnalysis = [ordered] @{
    Name       = 'Group Policy Content'
    Enabled    = $true
    Action     = $null
    Data       = $null
    Execute    = {
        Invoke-GPOZaurrContent
    }
    Processing = {

    }
    Variables  = @{

    }
    Overview   = {

    }
    Solution   = {
        foreach ($Key in $Script:Reporting['GPOAnalysis']['Data'].Keys) {
            New-HTMLTab -Name $Key {
                New-HTMLTable -DataTable $Script:Reporting['GPOAnalysis']['Data'][$Key] -Filtering -Title $Key
            }
        }
    }
}