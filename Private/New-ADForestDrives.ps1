function New-ADForestDrives {
    [cmdletbinding()]
    param(
        [string] $ForestName,
        [string] $ObjectDN
    )
    if (-not $Global:ADDrivesMapped) {
        if ($ForestName) {
            $Forest = Get-ADForest -Identity $ForestName
        } else {
            $Forest = Get-ADForest
        }
        if ($ObjectDN) {
            # This doesn't work because no Domain and no $Server
            $DNConverted = (ConvertFrom-Distinguishedname -DistinguishedName $ObjectDN -ToDC) -replace '=' -replace ','
            if (-not(Get-PSDrive -Name $DNConverted -ErrorAction SilentlyContinue)) {
                try {

                    if ($Server) {
                        $null = New-PSDrive -Name $DNConverted -Root '' -PsProvider ActiveDirectory -Server $Server.Hostname[0] -Scope Global -WhatIf:$false
                        Write-Verbose "New-ADForestDrives - Mapped drive $Domain / $($Server.Hostname[0])"
                    } else {
                        $null = New-PSDrive -Name $DNConverted -Root '' -PsProvider ActiveDirectory -Server $Domain -Scope Global -WhatIf:$false
                    }
                } catch {
                    Write-Warning "New-ADForestDrives - Couldn't map new AD psdrive for $Domain / $($Server.Hostname[0])"
                }
            }
        } else {
            foreach ($Domain in $Forest.Domains) {
                try {
                    $Server = Get-ADDomainController -Discover -DomainName $Domain
                    $DomainInformation = Get-ADDomain -Server $Server.Hostname[0]
                } catch {
                    Write-Warning "New-ADForestDrives - Can't process domain $Domain - $($_.Exception.Message)"
                    continue
                }
                $ObjectDN = $DomainInformation.DistinguishedName
                $DNConverted = (ConvertFrom-Distinguishedname -DistinguishedName $ObjectDN -ToDC) -replace '=' -replace ','
                if (-not(Get-PSDrive -Name $DNConverted -ErrorAction SilentlyContinue)) {
                    try {
                        if ($Server) {
                            $null = New-PSDrive -Name $DNConverted -Root '' -PsProvider ActiveDirectory -Server $Server.Hostname[0] -Scope Global -WhatIf:$false
                            Write-Verbose "New-ADForestDrives - Mapped drive $Domain / $Server"
                        } else {
                            $null = New-PSDrive -Name $DNConverted -Root '' -PsProvider ActiveDirectory -Server $Domain -Scope Global -WhatIf:$false
                        }
                    } catch {
                        Write-Warning "New-ADForestDrives - Couldn't map new AD psdrive for $Domain / $Server $($_.Exception.Message)"
                    }
                }
            }
        }
        $Global:ADDrivesMapped = $true
    }
}