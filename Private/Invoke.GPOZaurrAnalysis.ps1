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
        foreach ($Key in $Script:GPOConfiguration['GPOAnalysis']['Data'].Keys) {
            New-HTMLTab -Name $Key {
                New-HTMLTable -DataTable $Script:GPOConfiguration['GPOAnalysis']['Data'][$Key] -Filtering -Title $Key
            }
        }
    }
}