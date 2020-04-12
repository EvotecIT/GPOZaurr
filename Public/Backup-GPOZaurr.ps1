function Backup-GPOZaurr {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [int] $LimitProcessing,
        [validateset('All', 'Empty', 'Unlinked')][string[]] $Type = 'All',
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
            if ($Type -contains 'All') {
                Write-Verbose "Backup-GPOZaurr - Backing up GPO $($_.DisplayName) from $($_.DomainName)"
                $Count++
                try {
                    $BackupInfo = Backup-GPO -Guid $_.GUID -Domain $_.DomainName -Path $BackupFinalPath -ErrorAction Stop #-Server $QueryServer
                    $BackupInfo
                } catch {
                    Write-Warning "Backup-GPOZaurr - Backing up GPO $($_.DisplayName) from $($_.DomainName) failed: $($_.Exception.Message)"
                }
                if ($LimitProcessing -eq $Count) {
                    break
                }
            }
            if ($Type -notcontains 'All' -and $Type -contains 'Empty') {
                if ($_.ComputerSettingsAvailable -eq $false -and $_.UserSettingsAvailable -eq $false) {
                    Write-Verbose "Backup-GPOZaurr - Backing up GPO $($_.DisplayName) from $($_.DomainName)"
                    $Count++
                    try {
                        $BackupInfo = Backup-GPO -Guid $_.GUID -Domain $_.DomainName -Path $BackupFinalPath -ErrorAction Stop #-Server $QueryServer
                        $BackupInfo
                    } catch {
                        Write-Warning "Backup-GPOZaurr - Backing up GPO $($_.DisplayName) from $($_.DomainName) failed: $($_.Exception.Message)"
                    }
                    if ($LimitProcessing -eq $Count) {
                        break
                    }
                }
            }
            if ($Type -notcontains 'All' -and $Type -contains 'Unlinked') {
                if ($_.Linked -eq $false) {
                    Write-Verbose "Backup-GPOZaurr - Backing up GPO $($_.DisplayName) from $($_.DomainName)"
                    $Count++
                    try {
                        $BackupInfo = Backup-GPO -Guid $_.GUID -Domain $_.DomainName -Path $BackupFinalPath -ErrorAction Stop #-Server $QueryServer
                        $BackupInfo
                    } catch {
                        Write-Warning "Backup-GPOZaurr - Backing up GPO $($_.DisplayName) from $($_.DomainName) failed: $($_.Exception.Message)"
                    }
                    if ($LimitProcessing -eq $Count) {
                        break
                    }
                }
            }
        }
    }
    End {

    }
}