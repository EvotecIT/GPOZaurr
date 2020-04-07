function Remove-GPOZaurr {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory)][validateset('Empty', 'Unlinked', 'EmptyAndUnlinked')][string] $Type,
        [int] $LimitProcessing,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [string[]] $GPOPath,
        [string] $BackupPath,
        [switch] $BackupDated
    )
    Begin {
        if ($BackupPath) {
            $BackupRequired = $true
            if ($BackupDated) {
                $BackupFinalPath = "$BackupPath\$((Get-Date).ToString('yyyy-MM-dd_HH_mm_ss'))"
            } else {
                $BackupFinalPath = $BackupPath
            }
            Write-Verbose "Remove-GPOZaurr - Backing up to $BackupFinalPath"
            $null = New-Item -ItemType Directory -Path $BackupFinalPath -Force
        } else {
            $BackupRequired = $false
        }
        $Count = 0
    }
    Process {
        Get-GPOZaurr -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -GPOPath $GPOPath | ForEach-Object {
            #$ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation

            #$GPOSummary = foreach ($GPO in $GPOs) {
            #$QueryServer = $ForestInformation['QueryServers'][$_.Domain]['HostName'][0]
            if ($Type -eq 'Empty') {
                if ($_.ComputerSettingsAvailable -eq $false -and $_.UserSettingsAvailable -eq $false) {
                    if ($BackupRequired) {
                        try {
                            Write-Verbose "Remove-GPOZaurr - Backing up GPO $($_.Name) from $($_.Domain)"
                            $BackupInfo = Backup-GPO -Guid $_.Guid -Domain $_.Domain -Path $BackupFinalPath -ErrorAction Stop #-Server $QueryServer
                            $BackupInfo
                        } catch {
                            Write-Warning "Remove-GPOZaurr - Backing up GPO $($_.Name) from $($_.Domain) failed: $($_.Exception.Message)"

                        }
                    }
                    if (($BackupRequired -and $BackupInfo) -or (-not $BackupRequired)) {
                        try {
                            Write-Verbose "Remove-GPOZaurr - Removing GPO $($_.Name) from $($_.Domain)"
                            Remove-GPO -Domain $_.Domain -Guid $_.Guid -ErrorAction Stop #-Server $QueryServer
                        } catch {
                            Write-Warning "Remove-GPOZaurr - Removing GPO $($_.Name) from $($_.Domain) failed: $($_.Exception.Message)"
                        }
                    }
                    $Count++
                    if ($LimitProcessing -eq $Count) {
                        break
                    }
                }
            } elseif ($Type -eq 'EmptyAndUnlinked') {
                if ($_.ComputerSettingsAvailable -eq $false -and $_.UserSettingsAvailable -eq $false -or $_.Linked -eq $false) {

                    if ($BackupRequired) {
                        try {
                            Write-Verbose "Remove-GPOZaurr - Backing up GPO $($_.Name) from $($_.Domain)"
                            $BackupInfo = Backup-GPO -Guid $_.Guid -Domain $_.Domain -Path $BackupFinalPath -ErrorAction Stop #-Server $QueryServer
                            $BackupInfo
                        } catch {
                            Write-Warning "Remove-GPOZaurr - Backing up GPO $($_.Name) from $($_.Domain) failed: $($_.Exception.Message)"
                        }
                    }
                    if (($BackupRequired -and $BackupInfo) -or (-not $BackupRequired)) {
                        try {
                            Write-Verbose "Remove-GPOZaurr - Removing GPO $($_.Name) from $($_.Domain)"
                            Remove-GPO -Domain $_.Domain -Guid $_.Guid -ErrorAction Stop #-Server $QueryServer
                        } catch {
                            Write-Warning "Remove-GPOZaurr - Removing GPO $($_.Name) from $($_.Domain) failed: $($_.Exception.Message)"
                        }
                    }
                    $Count++
                    if ($LimitProcessing -eq $Count) {
                        break
                    }
                }
            } elseif ($Type -eq 'Unlinked') {
                if ($_.Linked -eq $false) {
                    if ($BackupRequired) {
                        try {
                            Write-Verbose "Remove-GPOZaurr - Backing up GPO $($_.Name) from $($_.Domain)"
                            $BackupInfo = Backup-GPO -Guid $_.Guid -Domain $_.Domain -Path $BackupFinalPath -ErrorAction Stop #-Server $QueryServer
                            $BackupInfo
                        } catch {
                            Write-Warning "Remove-GPOZaurr - Backing up GPO $($_.Name) from $($_.Domain) failed: $($_.Exception.Message)"
                        }
                    }
                    if (($BackupRequired -and $BackupInfo) -or (-not $BackupRequired)) {
                        try {
                            Write-Verbose "Remove-GPOZaurr - Removing GPO $($_.Name) from $($_.Domain)"
                            Remove-GPO -Domain $_.Domain -Guid $_.Guid -ErrorAction Stop #-Server $QueryServer
                        } catch {
                            Write-Warning "Remove-GPOZaurr - Removing GPO $($_.Name) from $($_.Domain) failed: $($_.Exception.Message)"
                        }
                    }
                    $Count++
                    if ($LimitProcessing -eq $Count) {
                        break
                    }
                }
            }
            #}
            #$GPOSummary
        }
    }
    End {

    }
}