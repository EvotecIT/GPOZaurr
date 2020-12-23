function Remove-GPOZaurrBroken {
    <#
    .SYNOPSIS
    Finds and removes broken Group Policies from SYSVOL or AD or both.

    .DESCRIPTION
    Finds and removes broken Group Policies from SYSVOL or AD or both. Assesment is based on Get-GPOZaurrBroken and there are 3 supported types:
    - AD - meaning GPOs which have no SYSVOL content will be deleted from AD
    - SYSVOL - meaning GPOs which have no AD content will be deleted from SYSVOL
    - ObjectClass - meaning GPOs which have ObjectClass category of Container rather than groupPolicyContainer will be deleted from AD & SYSVOL

    .PARAMETER Type
    Choose one or more types to delete. Options are AD, ObjectClass, SYSVOL

    .PARAMETER BackupPath
    Path to optional backup of SYSVOL content before deletion

    .PARAMETER BackupDated
    Forces backup to be created within folder that has date in it

    .PARAMETER LimitProcessing
    Allows to specify maximum number of items that will be fixed in a single run. It doesn't affect amount of GPOs processed

    .PARAMETER Forest
    Target different Forest, by default current forest is used

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned

    .PARAMETER ExtendedForestInformation
    Ability to provide Forest Information from another command to speed up processing

    .EXAMPLE
    Remove-GPOZaurrBroken -Verbose -WhatIf -Type AD, SYSVOL

    .EXAMPLE
    Remove-GPOZaurrBroken -Verbose -WhatIf -Type AD, SYSVOL -IncludeDomains 'ad.evotec.pl' -LimitProcessing 2

    .EXAMPLE
    Remove-GPOZaurrBroken -Verbose -IncludeDomains 'ad.evotec.xyz' -BackupPath $Env:UserProfile\Desktop\MyBackup1 -WhatIf -Type AD, SYSVOL

    .NOTES
    General notes
    #>
    [alias('Remove-GPOZaurrOrphaned')]
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory, Position = 0)][ValidateSet('SYSVOL', 'AD', 'ObjectClass')][string[]] $Type,
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
    Get-GPOZaurrBroken -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation | Where-Object {
        if ($Type -contains 'SYSVOL') {
            if ($_.Status -eq 'Not available in AD') {
                $_
            }
        }
        if ($Type -contains 'AD') {
            if ($_.Status -eq 'Not available on SYSVOL') {
                $_
            }
        }
        if ($Type -contains 'ObjectClass') {
            if ($_.Status -eq 'ObjectClass issue') {
                $_
            }
        }
    } | Select-Object | Select-Object -First $LimitProcessing | ForEach-Object {
        $GPO = $_
        if ($GPO.Status -in 'Not available in AD', 'ObjectClass issue') {
            Write-Verbose "Remove-GPOZaurrBroken - Removing from SYSVOL [$($GPO.Status)] $($GPO.Path)"
            if ($BackupFinalPath) {
                Try {
                    Write-Verbose "Remove-GPOZaurrBroken - Backing up $($GPO.Path)"
                    Copy-Item -LiteralPath $GPO.Path -Recurse -Destination $BackupFinalPath -ErrorAction Stop
                    $BackupWorked = $true
                } catch {
                    Write-Warning "Remove-GPOZaurrBroken - Error backing up $($GPO.Path) error: $($_.Exception.Message)"
                    $BackupWorked = $false
                }
            }
            if ($BackupWorked -or $BackupFinalPath -eq '') {
                Write-Verbose "Remove-GPOZaurrBroken - Removing $($GPO.Path)"
                try {
                    Remove-Item -Recurse -Force -LiteralPath $GPO.Path -ErrorAction Stop
                } catch {
                    Write-Warning "Remove-GPOZaurrBroken - Failed to remove file $($GPO.Path): $($_.Exception.Message)."
                }
            }
        }
        if ($GPO.Status -in 'Not available on SYSVOL', 'ObjectClass issue') {
            Write-Verbose "Remove-GPOZaurrBroken - Removing from AD [$($GPO.Status)] $($GPO.DistinguishedName)"
            try {
                $ExistingObject = Get-ADObject -Identity $GPO.DistinguishedName -Server $GPO.DomainName -ErrorAction Stop
            } catch {
                Write-Warning "Remove-GPOZaurrBroken - Error getting $($GPO.DistinguishedName) from AD error: $($_.Exception.Message)"
                $ExistingObject = $null
            }
            if ($ExistingObject -and $ExistingObject.ObjectClass -eq 'groupPolicyContainer') {
                Write-Verbose "Remove-GPOZaurrBroken - Removing DN: $($GPO.DistinguishedName) / ObjectClass: $($ExistingObject.ObjectClass)"
                try {
                    Remove-ADObject -Server $GPO.DomainName -Identity $GPO.DistinguishedName -Recursive -Confirm:$false -ErrorAction Stop
                } catch {
                    Write-Warning "Remove-GPOZaurrBroken - Failed to remove $($GPO.DistinguishedName) from AD error: $($_.Exception.Message)"
                }
            } else {
                Write-Warning "Remove-GPOZaurrBroken - DistinguishedName $($GPO.DistinguishedName) not found or ObjectClass is not groupPolicyContainer ($($ExistingObject.ObjectClass))"
            }
        }
    }
}