function Backup-GPOZaurr {
    <#
    .SYNOPSIS
    Provides Backup functionality to Group Policies

    .DESCRIPTION
    Provides Backup functionality to Group Policies

    .PARAMETER LimitProcessing
    Limits amount of GPOs that are backed up

    .PARAMETER Type
    Provides a way to backup only Empty or Unlinked GPOs. The default is All.

    .PARAMETER Forest
    Target different Forest, by default current forest is used

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned

    .PARAMETER ExtendedForestInformation
    Ability to provide Forest Information from another command to speed up processing

    .PARAMETER BackupPath
    Path where to keep the backup

    .PARAMETER BackupDated
    Whether cmdlet should created Dated folders for executed backup or not. Keep in mind it's not nessecary and two backups made to same folder have their dates properly tagged

    .EXAMPLE
    $GPOSummary = Backup-GPOZaurr -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -Type All
    $GPOSummary | Format-Table # only if you want to display output of backup

    .EXAMPLE
    $GPOSummary = Backup-GPOZaurr -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -Type All -BackupDated
    $GPOSummary | Format-Table # only if you want to display output of backup

    .NOTES
    General notes
    #>
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [int] $LimitProcessing,
        [validateset('All', 'Empty', 'Unlinked')][string[]] $Type = 'All',
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
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
        Get-GPOZaurr -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation | ForEach-Object {
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