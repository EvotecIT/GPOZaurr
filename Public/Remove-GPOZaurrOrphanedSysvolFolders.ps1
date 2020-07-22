function Remove-GPOZaurrOrphanedSysvolFolders {
    [cmdletBinding(SupportsShouldProcess)]
    param(
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
    Get-GPOZaurrSysvol -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation | Where-Object {
        if ($_.Status -eq 'Orphaned GPO') {
            $_
        }
    } | Select-Object | Select-Object -First $LimitProcessing | ForEach-Object {
        Write-Verbose "Remove-GPOZaurrOrphanedSysvolFolders - Processing $($_.Path)"
        if ($BackupFinalPath) {
            Try {
                Write-Verbose "Remove-GPOZaurrOrphanedSysvolFolders - Backing up $($_.Path)"
                Copy-Item -LiteralPath $_.Path -Recurse -Destination $BackupFinalPath -ErrorAction Stop
                $BackupWorked = $true
            } catch {
                Write-Warning "Remove-GPOZaurrOrphanedSysvolFolders - Error backing up error: $($_.Exception.Message)"
                $BackupWorked = $false
            }
        }
        if ($BackupWorked -or $BackupFinalPath -eq '') {
            Write-Verbose "Remove-GPOZaurrOrphanedSysvolFolders - Deleting $($_.Path)"
            try {
                Remove-Item -Recurse -Force -LiteralPath $_.Path
            } catch {
                $ErrorMessage = $_.Exception.Message
                Write-Warning "Remove-GPOZaurrOrphanedSysvolFolders - Failed to remove file $($_.Path): $($ErrorMessage)."
            }
        }
    }
}