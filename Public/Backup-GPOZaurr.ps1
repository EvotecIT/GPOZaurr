function Backup-GPOZaurr {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [int] $LimitProcessing,
        [validateset('All', 'Empty', 'Unlinked', 'EmptyAndUnlinked')][string] $Type = 'All',
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [string[]] $GPOPath,
        [string] $BackupPath,
        [switch] $BackupDated
    )
    Begin {
        if ($BackupDated) {
            $BackupFinalPath = "$BackupPath\$((Get-Date).ToString('yyyy-MM-dd_HH_mm_ss'))"
        } else {
            $BackupFinalPath = $BackupPath
        }
        Write-Verbose "Backup-GPOZaurr - Backing up to $BackupFinalPath"
        $null = New-Item -ItemType Directory -Path $BackupFinalPath -Force
        $Count = 0
    }
    Process {
        Get-GPOZaurr -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -GPOPath $GPOPath | ForEach-Object {
            #$ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
            #$GPOSummary = foreach ($GPO in $GPOs) {
            #$QueryServer = $ForestInformation['QueryServers'][$_.Domain]['HostName'][0]
            if ($Type -eq 'All') {
                Write-Verbose "Backup-GPOZaurr - Backing up GPO $($_.Name) from $($_.Domain)"
                $Count++
                try {
                    $BackupInfo = Backup-GPO -Guid $_.GUID -Domain $_.Domain -Path $BackupFinalPath -ErrorAction Stop #-Server $QueryServer
                    $BackupInfo
                } catch {
                    Write-Warning "Backup-GPOZaurr - Backing up GPO $($_.Name) from $($_.Domain) failed: $($_.Exception.Message)"
                }
                if ($LimitProcessing -eq $Count) {
                    break
                }
            } elseif ($Type -eq 'Empty') {
                if ($_.ComputerSettingsAvailable -eq $false -and $_.UserSettingsAvailable -eq $false) {
                    Write-Verbose "Backup-GPOZaurr - Backing up GPO $($_.Name) from $($_.Domain)"
                    $Count++
                    try {
                        $BackupInfo = Backup-GPO -Guid $_.GUID -Domain $_.Domain -Path $BackupFinalPath -ErrorAction Stop #-Server $QueryServer
                        $BackupInfo
                    } catch {
                        Write-Warning "Backup-GPOZaurr - Backing up GPO $($_.Name) from $($_.Domain) failed: $($_.Exception.Message)"
                    }
                    if ($LimitProcessing -eq $Count) {
                        break
                    }
                }
            } elseif ($Type -eq 'EmptyAndUnlinked') {
                if ($_.ComputerSettingsAvailable -eq $false -and $_.UserSettingsAvailable -eq $false -or $_.Linked -eq $false) {
                    Write-Verbose "Backup-GPOZaurr - Backing up GPO $($_.Name) from $($_.Domain)"
                    $Count++
                    try {
                        $BackupInfo = Backup-GPO -Guid $_.GUID -Domain $_.Domain -Path $BackupFinalPath -ErrorAction Stop #-Server $QueryServer
                        $BackupInfo
                    } catch {
                        Write-Warning "Backup-GPOZaurr - Backing up GPO $($_.Name) from $($_.Domain) failed: $($_.Exception.Message)"
                    }
                    if ($LimitProcessing -eq $Count) {
                        break
                    }
                }
            } elseif ($Type -eq 'Unlinked') {
                if ($_.Linked -eq $false) {
                    Write-Verbose "Backup-GPOZaurr - Backing up GPO $($_.Name) from $($_.Domain)"
                    $Count++
                    try {
                        $BackupInfo = Backup-GPO -Guid $_.GUID -Domain $_.Domain -Path $BackupFinalPath -ErrorAction Stop #-Server $QueryServer
                        $BackupInfo
                    } catch {
                        Write-Warning "Backup-GPOZaurr - Backing up GPO $($_.Name) from $($_.Domain) failed: $($_.Exception.Message)"
                    }
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