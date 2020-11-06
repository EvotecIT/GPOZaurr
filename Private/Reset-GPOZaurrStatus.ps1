function Reset-GPOZaurrStatus {
    param(

    )
    if (-not $Script:GPOConfigurationClean) {
        $Script:GPOConfigurationClean = Copy-Dictionary -Dictionary $Script:GPOConfiguration
    } else {
        $Script:GPOConfiguration = Copy-Dictionary -Dictionary $Script:GPOConfigurationClean
    }
    if (-not $Script:DefaultTypes) {
        $Script:DefaultTypes = foreach ($T in $Script:GPOConfiguration.Keys) {
            if ($Script:GPOConfiguration[$T].Enabled) {
                $T
            }
        }
    } else {
        foreach ($T in $Script:GPOConfiguration.Keys) {
            $Script:GPOConfiguration[$T]['Enabled'] = $false
        }
        foreach ($T in $Script:DefaultTypes) {
            $Script:GPOConfiguration[$T]['Enabled'] = $true
        }
    }
}