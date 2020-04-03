function Backup-GPOZaurr {
    [cmdletBinding()]
    param(
        [int] $LimitProcessing,
        [validateset('All', 'Empty', 'Unlinked', 'EmptyAndUnlinked')][string] $Type = 'All',
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [string[]] $GPOPath,
        [string] $BackupPath
    )
    # Logging Paths
    $DateDirectory = "$BackupPath\$((Get-Date).ToString('yyyy-MM-dd_HH_mm_ss'))"
    Write-Verbose "Backup-GPOZaurr - Backing up to $DateDirectory"

    $GPOs = Get-GPOZaurr -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -GPOPath $GPOPath
    #$ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation

    $Count = 0
    $null = New-Item -ItemType Directory -Path $DateDirectory -Force
    $GPOSummary = foreach ($GPO in $GPOs) {
        #$QueryServer = $ForestInformation['QueryServers'][$GPO.Domain]['HostName'][0]
        if ($Type -eq 'All') {
            Write-Verbose "Backup-GPOZaurr - Backing up GPO $($GPO.Name) from $($GPO.Domain)"
            $Count++
            try {
                $BackupInfo = Backup-GPO -Name $GPO.Name -Domain $GPO.Domain -Path $DateDirectory #-Server $QueryServer
                $BackupInfo
            } catch {
                Write-Warning "Backup-GPOZaurr - Backing up GPO $($GPO.Name) from $($GPO.Domain) using server $QueryServer failed: $($_.Exception.Message)"
            }
            if ($LimitProcessing -eq $Count) {
                break
            }
        } elseif ($Type -eq 'Empty') {
            if ($GPO.ComputerSettingsAvailable -eq $false -and $GPO.UserSettingsAvailable -eq $false) {
                Write-Verbose "Backup-GPOZaurr - Backing up GPO $($GPO.Name) from $($GPO.Domain)"
                $Count++
                try {
                    $BackupInfo = Backup-GPO -Name $GPO.Name -Domain $GPO.Domain -Path $DateDirectory #-Server $QueryServer
                    $BackupInfo
                } catch {
                    Write-Warning "Backup-GPOZaurr - Backing up GPO $($GPO.Name) from $($GPO.Domain) using server $QueryServer failed: $($_.Exception.Message)"
                }
                if ($LimitProcessing -eq $Count) {
                    break
                }
            }
        } elseif ($Type -eq 'EmptyAndUnlinked') {
            if ($GPO.ComputerSettingsAvailable -eq $false -and $GPO.UserSettingsAvailable -eq $false -or $Gpo.Linked -eq $false) {
                Write-Verbose "Backup-GPOZaurr - Backing up GPO $($GPO.Name) from $($GPO.Domain)"
                $Count++
                try {
                    $BackupInfo = Backup-GPO -Name $GPO.Name -Domain $GPO.Domain -Path $DateDirectory #-Server $QueryServer
                    $BackupInfo
                } catch {
                    Write-Warning "Backup-GPOZaurr - Backing up GPO $($GPO.Name) from $($GPO.Domain) using server $QueryServer failed: $($_.Exception.Message)"
                }
                if ($LimitProcessing -eq $Count) {
                    break
                }
            }
        } elseif ($Type -eq 'Unlinked') {
            if ($Gpo.Linked -eq $false) {
                Write-Verbose "Backup-GPOZaurr - Backing up GPO $($GPO.Name) from $($GPO.Domain)"
                $Count++
                try {
                    $BackupInfo = Backup-GPO -Name $GPO.Name -Domain $GPO.Domain -Path $DateDirectory #-Server $QueryServer
                    $BackupInfo
                } catch {
                    Write-Warning "Backup-GPOZaurr - Backing up GPO $($GPO.Name) from $($GPO.Domain) using server $QueryServer failed: $($_.Exception.Message)"
                }
                if ($LimitProcessing -eq $Count) {
                    break
                }
            }
        }
    }
    $GPOSummary
}