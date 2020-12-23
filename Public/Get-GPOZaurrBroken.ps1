function Get-GPOZaurrBroken {
    <#
    .SYNOPSIS
    Detects broken or otherwise damaged Group Policies

    .DESCRIPTION
    Detects broken or otherwise damaged Group Policies providing insight whether GPO exists in both AD and SYSVOL.
    It provides few statuses:
    - Permissions issue - means account couldn't read GPO due to permissions
    - ObjectClass issue - means that ObjectClass is of type Container, rather than expected groupPolicyContainer
    - Not available on SYSVOL - means SYSVOL data is missing, yet AD metadata is available
    - Not available in AD - means AD metadata is missing, yet SYSVOL data is available
    - Exists - means AD metadata and SYSVOL data are available

    .PARAMETER Forest
    Target different Forest, by default current forest is used

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER ExcludeDomainControllers
    Exclude specific domain controllers, by default there are no exclusions, as long as VerifyDomainControllers switch is enabled. Otherwise this parameter is ignored.

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned

    .PARAMETER IncludeDomainControllers
    Include only specific domain controllers, by default all domain controllers are included, as long as VerifyDomainControllers switch is enabled. Otherwise this parameter is ignored.

    .PARAMETER SkipRODC
    Skip Read-Only Domain Controllers. By default all domain controllers are included.

    .PARAMETER ExtendedForestInformation
    Ability to provide Forest Information from another command to speed up processing

    .PARAMETER VerifyDomainControllers
    Forces cmdlet to check GPO Existance on Domain Controllers rather then per domain

    .EXAMPLE
    Get-GPOZaurrBroken -Verbose | Format-Table

    .NOTES
    General notes
    #>
    [alias('Get-GPOZaurrSysvol')]
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [string[]] $ExcludeDomainControllers,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [alias('DomainControllers')][string[]] $IncludeDomainControllers,
        [switch] $SkipRODC,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [switch] $VerifyDomainControllers
    )
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExcludeDomainControllers $ExcludeDomainControllers -IncludeDomainControllers $IncludeDomainControllers -SkipRODC:$SkipRODC -ExtendedForestInformation $ExtendedForestInformation -Extended
    foreach ($Domain in $ForestInformation.Domains) {
        $TimeLog = Start-TimeLog
        Write-Verbose "Get-GPOZaurrBroken - Starting process for $Domain"
        $QueryServer = $ForestInformation['QueryServers']["$Domain"].HostName[0]
        $SystemsContainer = $ForestInformation['DomainsExtended'][$Domain].SystemsContainer
        $PoliciesAD = @{}
        if ($SystemsContainer) {
            $PoliciesSearchBase = -join ("CN=Policies,", $SystemsContainer)
            $PoliciesInAD = Get-ADObject -SearchBase $PoliciesSearchBase -SearchScope OneLevel -Filter * -Server $QueryServer -Properties Name, gPCFileSysPath, DisplayName, DistinguishedName, Description, Created, Modified, ObjectClass, ObjectGUID
            foreach ($Policy in $PoliciesInAD) {
                $GUIDFromDN = ConvertFrom-DistinguishedName -DistinguishedName $Policy.DistinguishedName
                if ($Policy.ObjectClass -eq 'Container') {
                    # This usually means GPO deletion process somehow failed and while object itself stayed it isn't groupPolicyContainer anymore
                    $PoliciesAD[$GUIDFromDN] = 'ObjectClass issue'
                } else {
                    $GUID = $Policy.Name
                    if ($GUID -and $GUIDFromDN) {
                        $PoliciesAD[$GUIDFromDN] = 'Exists'
                    } else {
                        $PoliciesAD[$GUIDFromDN] = 'Permissions issue'
                    }
                }
            }
        } else {
            Write-Warning "Get-GPOZaurrBroken - Couldn't get GPOs from $Domain. Skipping"
        }
        if ($PoliciesInAD.Count -ge 2) {
            if (-not $VerifyDomainControllers) {
                Test-SysVolFolders -GPOs $PoliciesInAD -Server $Domain -Domain $Domain -PoliciesAD $PoliciesAD -PoliciesSearchBase $PoliciesSearchBase
            } else {
                foreach ($Server in $ForestInformation['DomainDomainControllers']["$Domain"]) {
                    Write-Verbose "Get-GPOZaurrBroken - Processing $Domain \ $($Server.HostName.Trim())"
                    Test-SysVolFolders -GPOs $PoliciesInAD -Server $Server.Hostname -Domain $Domain -PoliciesAD $PoliciesAD -PoliciesSearchBase $PoliciesSearchBase
                }
            }
        } else {
            Write-Warning "Get-GPOZaurrBroken - GPO count for $Domain is less then 2. This is not expected for fully functioning domain. Skipping processing SYSVOL folder."
        }
        $TimeEnd = Stop-TimeLog -Time $TimeLog -Option OneLiner
        Write-Verbose "Get-GPOZaurrBroken - Finishing process for $Domain (Time to process: $TimeEnd)"
    }
}