function Remove-GPOZaurrFolders {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [string] $BackupPath,
        [switch] $BackupDated,
        [ValidateSet('All', 'Netlogon', 'Sysvol')][string[]] $Type = 'All',
        [Parameter(Mandatory)][ValidateSet('NTFRS', 'Empty')][string] $FolderType,
        [string[]] $FolderName,
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

    Get-GPOZaurrFolders -Type $Type -FolderType $FolderType -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation | Where-Object {
        if ($FolderName) {
            foreach ($Folder in $FolderName) {
                if ($_.Name -eq $Folder) {
                    $_
                }
            }
        } else {
            $_
        }
    } | Select-Object | Select-Object -First $LimitProcessing | ForEach-Object {
        if ($BackupFinalPath) {
            $SYSVOLRoot = "\\$($_.DomainName)\SYSVOL\$($_.DomainName)\"
            $DestinationFile = ($_.FullName).Replace($SYSVOLRoot, '')
            #$DestinationMissingFolder = $DestinationFile.Replace($DestinationFile, '')
            $DestinationFilePath = [system.io.path]::Combine($BackupFinalPath, $DestinationFile)
            #$DestinationFolderPath = [system.io.path]::Combine($BackupFinalPath, $DestinationMissingFolder)

            Write-Verbose "Remove-GPOZaurrFolders - Backing up $($_.FullName)"
            Try {
                Copy-Item -LiteralPath $_.FullName -Recurse -Destination $DestinationFilePath -ErrorAction Stop -Force
                $BackupWorked = $true
            } catch {
                Write-Warning "Remove-GPOZaurrFolders - Error backing up error: $($_.Exception.Message)"
                $BackupWorked = $false
            }

        }
        if ($BackupWorked -or $BackupFinalPath -eq '') {
            try {
                Write-Verbose "Remove-GPOZaurrFolders - Removing $($_.FullName)"
                Remove-Item -Path $_.FullName -Force -Recurse
            } catch {
                Write-Warning "Remove-GPOZaurrFolders - Failed to remove directory $($_.FullName): $($_.Exception.Message)."
            }
        }
    }
}