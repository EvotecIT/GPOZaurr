function Restore-GPOZaurr {
    <#
    .SYNOPSIS
    Restores Group Policy Objects (GPOs) from a specified backup folder.

    .DESCRIPTION
    Restores Group Policy Objects (GPOs) from a specified backup folder. This function allows restoring GPOs with the option to provide a new display name for the GPO.

    .PARAMETER BackupFolder
    The path to the folder containing the GPO backups.

    .PARAMETER DisplayName
    The display name of the GPO to be restored.

    .PARAMETER NewDisplayName
    (Optional) The new display name for the restored GPO.

    .PARAMETER Domain
    (Optional) The domain name where the GPO should be restored.

    .PARAMETER SkipBackupSummary
    (Switch) Skip displaying the backup summary information.

    .EXAMPLE
    Restore-GPOZaurr -BackupFolder 'C:\GPOBackups' -DisplayName 'TestGPO'

    .EXAMPLE
    Restore-GPOZaurr -BackupFolder 'C:\GPOBackups' -DisplayName 'TestGPO' -NewDisplayName 'NewTestGPO' -Domain 'example.com'

    .NOTES
    General notes
    #>
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
                        [Array] $FoundGPO = $BackupSummary | Where-Object { $_.DisplayName -eq $DisplayName -and $_.DomainName -eq $Domain }
                    } else {
                        [Array] $FoundGPO = $BackupSummary | Where-Object { $_.DisplayName -eq $DisplayName }
                    }
                    foreach ($GPO in $FoundGPO) {
                        if ($NewDisplayName) {
                            Import-GPO -Path $BackupFolder -BackupID $GPO.ID -Domain $GPO.Domain -TargetName $NewDisplayName -CreateIfNeeded
                        } else {
                            Write-Verbose "Restore-GPOZaurr - Restoring GPO $($GPO.DisplayName) from $($GPO.DomainName) / BackupId: $($GPO.ID)"
                            try {
                                Restore-GPO -Path $BackupFolder -BackupID $GPO.ID -Domain $GPO.DomainName
                            } catch {
                                Write-Warning "Restore-GPOZaurr - Restoring GPO $($GPO.DisplayName) from $($GPO.DomainName) failed: $($_.Exception.Message)"
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
                    Write-Verbose "Restore-GPOZaurr - Restoring GPO $($GPO.DisplayName) from $($GPO.DomainName) / BackupId: $($GPO.ID)"
                    try {
                        Restore-GPO -Path $BackupFolder -Domain $GPO.DomainName -BackupId $GPO.ID
                    } catch {
                        Write-Warning "Restore-GPOZaurr - Restoring GPO $($GPO.DisplayName) from $($GPO.DomainName) failed: $($_.Exception.Message)"
                    }
                }
            }
        } else {
            Write-Warning "Restore-GPOZaurr - BackupFolder incorrect ($BackupFolder)"
        }
    }
}