function Remove-GPOZaurrFolders {
    <#
    .SYNOPSIS
    Removes specified GPOZaurr folders and backs them up to a specified path.

    .DESCRIPTION
    This function removes specified GPOZaurr folders based on the provided criteria and backs them up to a specified path. It allows for filtering by folder type, domain, and other parameters.

    .PARAMETER BackupPath
    The path where the GPOZaurr folders will be backed up.

    .PARAMETER BackupDated
    Indicates whether the backup path should include a timestamp.

    .PARAMETER Type
    Specifies the type of folders to remove. Options are 'All', 'Netlogon', or 'Sysvol'.

    .PARAMETER FolderType
    Specifies the type of folders to remove. Options are 'NTFRS' or 'Empty'.

    .PARAMETER FolderName
    Specifies the name of the folder to remove.

    .PARAMETER LimitProcessing
    Limits the number of folders to process.

    .PARAMETER Forest
    Specifies the forest to target.

    .PARAMETER ExcludeDomains
    Specifies domains to exclude from processing.

    .PARAMETER IncludeDomains
    Specifies domains to include in processing.

    .PARAMETER ExtendedForestInformation
    Specifies additional forest information.

    .EXAMPLE
    Remove-GPOZaurrFolders -BackupPath "C:\Backups" -BackupDated -Type 'All' -FolderType 'NTFRS' -FolderName "Folder1" -LimitProcessing 10 -Forest "ExampleForest" -ExcludeDomains "Domain1" -IncludeDomains "Domain2" -ExtendedForestInformation $info
    Removes GPOZaurr folders of type 'NTFRS' named "Folder1" from all domains in the forest "ExampleForest", backs them up to "C:\Backups" with a timestamp, and limits processing to 10 folders.

    #>
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