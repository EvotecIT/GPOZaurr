function Remove-GPOZaurrBroken {
    [alias('Remove-GPOZaurrOrphaned')]
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateSet('SYSVOL', 'AD')][string[]] $Type = @('SYSVOL', 'AD'),
        [string] $BackupPath,
        [switch] $BackupDated,
        [int] $LimitProcessing = [int32]::MaxValue,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    if ($BackupPath) {
        if ($BackupDated) {
            $BackupFinalPath = "$BackupPath\$((Get-Date).ToString('yyyy-MM-dd_HH_mm_ss'))"
        } else {
            $BackupFinalPath = $BackupPath
        }
    } else {
        $BackupFinalPath = ''
    }
    Get-GPOZaurrBroken -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation | Where-Object {
        if ($Type -contains 'SYSVOL') {
            if ($_.Status -eq 'Not available in AD') {
                $_
            }
        }
        if ($Type -contains 'AD') {
            if ($_.Status -eq 'Not available on SYSVOL') {
                $_
            }
        }
    } | Select-Object | Select-Object -First $LimitProcessing | ForEach-Object {
        $GPO = $_
        if ($GPO.Status -eq 'Not available in AD') {
            Write-Verbose "Remove-GPOZaurrBroken - Processing [AD] $($GPO.Path)"
            if ($BackupFinalPath) {
                Try {
                    Write-Verbose "Remove-GPOZaurrBroken - Backing up $($GPO.Path)"
                    Copy-Item -LiteralPath $GPO.Path -Recurse -Destination $BackupFinalPath -ErrorAction Stop
                    $BackupWorked = $true
                } catch {
                    Write-Warning "Remove-GPOZaurrBroken - Error backing up $($GPO.Path) error: $($_.Exception.Message)"
                    $BackupWorked = $false
                }
            }
            if ($BackupWorked -or $BackupFinalPath -eq '') {
                Write-Verbose "Remove-GPOZaurrBroken - Deleting $($GPO.Path)"
                try {
                    Remove-Item -Recurse -Force -LiteralPath $GPO.Path -ErrorAction Stop
                } catch {
                    Write-Warning "Remove-GPOZaurrBroken - Failed to remove file $($GPO.Path): $($_.Exception.Message)."
                }
            }
        } elseif ($GPO.Status -eq 'Not available on SYSVOL') {
            Write-Verbose "Remove-GPOZaurrBroken - Processing [SYSVOL] $($GPO.DistinguishedName)"
            try {
                $ExistingObject = Get-ADObject -Identity $GPO.DistinguishedName -Server $GPO.DomainName -ErrorAction Stop
            } catch {
                Write-Warning "Remove-GPOZaurrBroken - Error getting $($GPO.DistinguishedName) from AD error: $($_.Exception.Message)"
                $ExistingObject = $null
            }
            if ($ExistingObject -and $ExistingObject.ObjectClass -eq 'groupPolicyContainer') {
                Write-Verbose "Remove-GPOZaurrBroken - Removing DN: $($GPO.DistinguishedName) / ObjectClass: $($ExistingObject.ObjectClass)"
                try {
                    Remove-ADObject -Server $GPO.DomainName -Identity $GPO.DistinguishedName -Recursive -Confirm:$false -ErrorAction Stop
                } catch {
                    Write-Warning "Remove-GPOZaurrBroken - Failed to remove $($GPO.DistinguishedName) from AD error: $($_.Exception.Message)"
                }
            } else {
                Write-Warning "Remove-GPOZaurrBroken - DistinguishedName $($GPO.DistinguishedName) not found or ObjectClass is not groupPolicyContainer ($($ExistingObject.ObjectClass))"
            }
        }
    }
}