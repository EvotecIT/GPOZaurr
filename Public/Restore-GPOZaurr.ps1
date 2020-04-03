function Restore-GPOZaurr {
    [cmdletBinding()]
    param(
        [parameter(Mandatory)][string] $BackupFolder,
        [alias('Name')][string] $DisplayName,
        [string] $NewDisplayName,
        [string] $Domain,
        [switch] $SkipBackupSummary
    )
    if ($BackupFolder) {
        if (Test-Path -LiteralPath $BackupFolder) {
            if ($DisplayName) {
                if (-not $SkipBackupSummary) {
                    $BackupSummary = Get-GPOZaurrBackupInformation -BackupFolder $BackupFolder
                    if ($Domain) {
                        [Array] $FoundGPO = $BackupSummary | Where-Object { $_.DisplayName -eq $DisplayName -and $_.Domain -eq $Domain }
                    } else {
                        [Array] $FoundGPO = $BackupSummary | Where-Object { $_.DisplayName -eq $DisplayName }
                    }
                    foreach ($GPO in $FoundGPO) {
                        if ($NewDisplayName) {
                            Import-GPO -Path $BackupFolder -BackupID $GPO.ID -Domain $GPO.Domain -TargetName $NewDisplayName -CreateIfNeeded
                        } else {
                            Write-Verbose "Restore-GPOZaurr - Restoring GPO $($GPO.DisplayName) from $($GPO.Domain) / BackupId: $($GPO.ID)"
                            try {
                                Restore-GPO -Path $BackupFolder -BackupID $GPO.ID -Domain $GPO.Domain
                            } catch {
                                Write-Warning "Restore-GPOZaurr - Restoring GPO $($GPO.DisplayName) from $($_.Domain) failed: $($_.Exception.Message)"
                            }
                        }
                    }
                } else {
                    if ($Domain) {
                        Write-Verbose "Restore-GPOZaurr - Restoring GPO $($Name) from $($Domain)"
                        try {
                            Restore-GPO -Path $BackupFolder -Name $Name -Domain $Domain
                        } catch {
                            Write-Warning "Restore-GPOZaurr - Restoring GPO $($Name) from $($Domain) failed: $($_.Exception.Message)"
                        }
                    } else {
                        Write-Verbose "Restore-GPOZaurr - Restoring GPO $($Name)"
                        try {
                            Restore-GPO -Path $BackupFolder -Name $Name
                        } catch {
                            Write-Warning "Restore-GPOZaurr - Restoring GPO $($Name) failed: $($_.Exception.Message)"
                        }
                    }
                }
            } else {
                $BackupSummary = Get-GPOZaurrBackupInformation -BackupFolder $BackupFolder
                foreach ($GPO in $BackupSummary) {
                    Write-Verbose "Restore-GPOZaurr - Restoring GPO $($GPO.DisplayName) from $($GPO.Domain) / BackupId: $($GPO.ID)"
                    try {
                        Restore-GPO -Path $BackupFolder -Domain $GPO.Domain -BackupId $GPO.ID
                    } catch {
                        Write-Warning "Restore-GPOZaurr - Restoring GPO $($GPO.DisplayName) from $($GPO.Domain) failed: $($_.Exception.Message)"
                    }
                }
            }
        } else {
            Write-Warning "Restore-GPOZaurr - BackupFolder incorrect ($BackupFolder)"
        }
    }
}