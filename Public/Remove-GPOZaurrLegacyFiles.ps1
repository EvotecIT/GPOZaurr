function Remove-GPOZaurrLegacyFiles {
    <#
    .SYNOPSIS
    Removes legacy Group Policy Objects (GPO) files from specified domains.

    .DESCRIPTION
    The Remove-GPOZaurrLegacyFiles function removes legacy GPO files from specified domains. It can back up the files before removal and optionally remove empty folders.

    .PARAMETER BackupPath
    Specifies the path where backup files will be stored.

    .PARAMETER BackupDated
    Indicates whether backup files should be timestamped with the current date and time.

    .PARAMETER RemoveEmptyFolders
    Indicates whether empty folders should be removed after GPO files are deleted.

    .PARAMETER Forest
    Specifies the forest where the GPO files are located.

    .PARAMETER ExcludeDomains
    Specifies an array of domains to exclude from processing.

    .PARAMETER IncludeDomains
    Specifies an array of domains to include for processing.

    .PARAMETER LimitProcessing
    Specifies the maximum number of GPO files to process.

    .EXAMPLE
    Remove-GPOZaurrLegacyFiles -BackupPath "C:\GPOBackups" -BackupDated -RemoveEmptyFolders -Forest "Contoso" -IncludeDomains "Domain1", "Domain2" -ExcludeDomains "Domain3" -LimitProcessing 100
    Removes legacy GPO files from the "Contoso" forest for "Domain1" and "Domain2", excluding "Domain3". Backs up files to "C:\GPOBackups" with timestamps and removes empty folders after deletion.

    #>
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [string] $BackupPath,
        [switch] $BackupDated,
        [switch] $RemoveEmptyFolders,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,

        [int] $LimitProcessing = [int32]::MaxValue
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
    $Splat = @{
        Forest                    = $Forest
        IncludeDomains            = $IncludeDomains
        ExcludeDomains            = $ExcludeDomains
        ExtendedForestInformation = $ExtendedForestInformation
        Verbose                   = $VerbosePreference
    }
    [Array] $Deleted = Get-GPOZaurrLegacyFiles @Splat | Select-Object -First $LimitProcessing | ForEach-Object {
        Write-Verbose "Remove-GPOZaurrLegacyFiles - Processing $($_.FullName)"
        if ($BackupFinalPath) {
            $SYSVOLRoot = "\\$($_.DomainName)\SYSVOL\$($_.DomainName)\policies\"
            $DestinationFile = ($_.FullName).Replace($SYSVOLRoot, '')
            #$DestinationMissingFolder = $DestinationFile.Replace($DestinationFile, '')
            $DestinationFilePath = [system.io.path]::Combine($BackupFinalPath, $DestinationFile)
            #$DestinationFolderPath = [system.io.path]::Combine($BackupFinalPath, $DestinationMissingFolder)

            Write-Verbose "Remove-GPOZaurrLegacyFiles - Backing up $($_.FullName)"
            $Created = New-Item -ItemType File -Path $DestinationFilePath -Force
            if ($Created) {
                Try {
                    Copy-Item -LiteralPath $_.FullName -Recurse -Destination $DestinationFilePath -ErrorAction Stop -Force
                    $BackupWorked = $true
                } catch {
                    Write-Warning "Remove-GPOZaurrLegacyFiles - Error backing up error: $($_.Exception.Message)"
                    $BackupWorked = $false
                }
            } else {
                $BackupWorked = $false
            }
        }
        if ($BackupWorked -or $BackupFinalPath -eq '') {
            try {
                Write-Verbose "Remove-GPOZaurrLegacyFiles - Deleting $($_.FullName)"
                Remove-Item -Path $_.FullName -ErrorAction Stop -Force
                $_
            } catch {
                Write-Warning "Remove-GPOZaurrLegacyFiles - Failed to remove file $($_.FullName): $($_.Exception.Message)."
            }
        }
    }
    if ($Deleted.Count -gt 0) {
        if ($RemoveEmptyFolders) {
            $FoldersToCheck = $Deleted.DirectoryName | Sort-Object -Unique
            foreach ($Folder in $FoldersToCheck) {
                $FolderName = $Folder.Substring($Folder.Length - 4)
                if ($FolderName -eq '\Adm') {
                    try {
                        $MeasureCount = Get-ChildItem -LiteralPath $Folder -Force -ErrorAction Stop | Select-Object -First 1 | Measure-Object
                    } catch {
                        Write-Warning "Remove-GPOZaurrLegacyFiles - Couldn't verify if folder $Folder is empty. Skipping. Error: $($_.Exception.Message)."
                        continue
                    }
                    if ($MeasureCount.Count -eq 0) {
                        Write-Verbose "Remove-GPOZaurrLegacyFiles - Deleting empty folder $($Folder)"
                        try {
                            Remove-Item -LiteralPath $Folder -Force -Recurse:$false
                        } catch {
                            Write-Warning "Remove-GPOZaurrLegacyFiles - Failed to remove folder $($Folder): $($_.Exception.Message)."
                        }
                    } else {
                        Write-Verbose "Remove-GPOZaurrLegacyFiles - Skipping not empty folder from deletion $($Folder)"
                    }
                }
            }
        }
    }
}