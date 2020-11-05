$GPOZaurrSysVolLegacyFiles = [ordered] @{
    Name       = 'SYSVOL Legacy ADM Files'
    Enabled    = $false
    Action     = $null
    Data       = $null
    Execute    = {
        Get-GPOZaurrLegacyFiles
    }
    Processing = {

    }
    Variables  = @{

    }
    Overview   = {

    }
    Solution   = {
        New-HTMLTable -DataTable $GPOZaurrSysVolLegacyFiles['Data'] -Filtering
    }
}