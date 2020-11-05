$GPOZaurrAnalysis = [ordered] @{
    Name       = 'Group Policy Content'
    Enabled    = $true
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
        foreach ($Key in $GPOZaurrAnalysis['Data'].Keys) {
            New-HTMLTab -Name $Key {
                New-HTMLTable -DataTable $GPOZaurrAnalysis['Data'][$Key] -Filtering -Title $Key
            }
        }
    }
}