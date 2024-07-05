function Remove-GPOZaurr {
    <#
    .SYNOPSIS
    Removes Group Policy Objects based on specified criteria.

    .DESCRIPTION
    The Remove-GPOZaurr function removes Group Policy Objects (GPOs) based on the specified criteria. It allows for filtering by various parameters such as GPO type, forest, domains, and more.

    .PARAMETER ExcludeGroupPolicies
    Specifies the Group Policies to exclude from removal.

    .PARAMETER Type
    Specifies the type of GPOs to target for removal. Valid values are 'Empty', 'Unlinked', 'Disabled', 'NoApplyPermission'.

    .PARAMETER LimitProcessing
    Specifies the maximum number of GPOs to process before stopping.

    .PARAMETER Forest
    Specifies the forest to target for GPO removal.

    .PARAMETER ExcludeDomains
    Specifies the domains to exclude from GPO removal.

    .PARAMETER IncludeDomains
    Specifies the domains to include for GPO removal.

    .PARAMETER ExtendedForestInformation
    Specifies additional information about the forest.

    .PARAMETER GPOPath
    Specifies the path to the GPOs to be removed.

    .PARAMETER BackupPath
    Specifies the path for backing up GPOs before removal.

    .PARAMETER BackupDated
    Indicates whether the backup should be dated.

    .PARAMETER RequireDays
    Specifies the number of days before GPO removal is required.

    .EXAMPLE
    Remove-GPOZaurr -Type 'Empty' -Forest 'Contoso' -IncludeDomains 'Domain1', 'Domain2' -BackupPath 'C:\GPOBackups' -BackupDated -RequireDays 7
    Removes all empty GPOs from the 'Contoso' forest for 'Domain1' and 'Domain2', backs them up to 'C:\GPOBackups' with dated folders, and requires removal after 7 days.

    .EXAMPLE
    Remove-GPOZaurr -Type 'Disabled' -Forest 'Fabrikam' -ExcludeDomains 'Domain3' -LimitProcessing 10
    Removes all disabled GPOs from the 'Fabrikam' forest excluding 'Domain3' and processes only the first 10 GPOs.

    #>
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 1)][scriptblock] $ExcludeGroupPolicies,
        [parameter(Position = 0, Mandatory)][validateset('Empty', 'Unlinked', 'Disabled', 'NoApplyPermission')][string[]] $Type,
        [int] $LimitProcessing,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [string[]] $GPOPath,
        [string] $BackupPath,
        [switch] $BackupDated,
        [int] $RequireDays
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
            $null = New-Item -ItemType Directory -Path $BackupFinalPath -Force -WhatIf:$false
        } else {
            $BackupRequired = $false
        }
        $CountProcessedGPO = 0
    }
    Process {
        $getGPOZaurrSplat = @{
            Forest                    = $Forest
            IncludeDomains            = $IncludeDomains
            ExcludeDomains            = $ExcludeDomains
            ExtendedForestInformation = $ExtendedForestInformation
            GPOPath                   = $GPOPath
            ExcludeGroupPolicies      = $ExcludeGroupPolicies
        }

        Get-GPOZaurr @getGPOZaurrSplat | ForEach-Object {
            if ($LimitProcessing -ne 0 -and $CountProcessedGPO -ge $LimitProcessing) {
                Write-Warning -Message "Remove-GPOZaurr - LimitProcessing ($CountProcessedGPO / $LimitProcessing) reached. Stopping processing"
                break
            }

            $DeleteRequired = $false

            if ($Type -contains 'Empty') {
                if ($_.Empty -eq $true) {
                    $DeleteRequired = $true
                }
            }
            if ($Type -contains 'Unlinked') {
                if ($_.Linked -eq $false) {
                    $DeleteRequired = $true
                }
            }
            if ($Type -contains 'Disabled') {
                if ($_.Enabled -eq $false) {
                    $DeleteRequired = $true
                }
            }
            if ($Type -contains 'NoApplyPermission') {
                if ($_.ApplyPermission -eq $false) {
                    $DeleteRequired = $true
                }
            }
            if ($RequireDays) {
                if ($RequireDays -ge $_.Days) {
                    # GPO was modified recently and we don't want to touch it yet, maybe edit is in progress
                    $DeleteRequired = $false
                }
            }
            if ($_.Exclude -eq $true) {
                Write-Verbose "Remove-GPOZaurr - Excluded GPO $($_.DisplayName) from $($_.DomainName). Skipping!"
            } elseif ($DeleteRequired) {
                if ($BackupRequired) {
                    try {
                        Write-Verbose "Remove-GPOZaurr - Backing up GPO $($_.DisplayName) from $($_.DomainName)"
                        $BackupInfo = Backup-GPO -Guid $_.Guid -Domain $_.DomainName -Path $BackupFinalPath -ErrorAction Stop
                        $BackupInfo
                        $BackupOK = $true
                    } catch {
                        Write-Warning "Remove-GPOZaurr - Backing up GPO $($_.DisplayName) from $($_.DomainName) failed: $($_.Exception.Message)"
                        $BackupOK = $false
                    }
                }
                if (($BackupRequired -and $BackupOK) -or (-not $BackupRequired)) {
                    try {
                        Write-Verbose "Remove-GPOZaurr - Removing GPO $($_.DisplayName) from $($_.DomainName)"
                        Remove-GPO -Domain $_.DomainName -Guid $_.Guid -ErrorAction Stop
                    } catch {
                        Write-Warning "Remove-GPOZaurr - Removing GPO $($_.DisplayName) from $($_.DomainName) failed: $($_.Exception.Message)"
                    }
                }
                $CountProcessedGPO++
            }
        }
    }
    End {

    }
}