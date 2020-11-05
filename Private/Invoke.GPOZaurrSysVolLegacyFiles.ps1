$GPOZaurrSysVolLegacyFiles = [ordered] @{
    Name       = 'SYSVOL Legacy ADM Files'
    Enabled    = $false
    Data       = $null
    Execute    = {
        $ADMLegacyFiles = Get-GPOZaurrLegacyFiles
     }
    Processing = {

    }
    Variables  = @{

    }
    Overview   = {

    }
    Solution   = {

    }
}