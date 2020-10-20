function Get-GPOZaurrBroken {
    [alias('Get-GPOZaurrSysvol')]
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [string[]] $ExcludeDomainControllers,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [alias('DomainControllers')][string[]] $IncludeDomainControllers,
        [switch] $SkipRODC,
        [Array] $GPOs,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [switch] $VerifyDomainControllers
    )
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExcludeDomainControllers $ExcludeDomainControllers -IncludeDomainControllers $IncludeDomainControllers -SkipRODC:$SkipRODC -ExtendedForestInformation $ExtendedForestInformation -Extended
    foreach ($Domain in $ForestInformation.Domains) {
        Write-Verbose "Get-WinADGPOSysvolFolders - Processing $Domain"
        $QueryServer = $ForestInformation['QueryServers']["$Domain"].HostName[0]
        $SystemsContainer = $ForestInformation['DomainsExtended'][$Domain].SystemsContainer
        $PoliciesAD = @{}
        if ($SystemsContainer) {
            $PoliciesSearchBase = -join ("CN=Policies,", $SystemsContainer)
            $PoliciesInAD = Get-ADObject -SearchBase $PoliciesSearchBase -SearchScope OneLevel -Filter * -Server $QueryServer
            foreach ($Policy in $PoliciesInAD) {
                $GUIDFromDN = ConvertFrom-DistinguishedName -DistinguishedName $Policy.DistinguishedName
                $GUIDFromDN = $GUIDFromDN -replace '{' -replace '}'
                $GUID = $Policy.Name -replace '{' -replace '}'
                if ($GUID -and $GUIDFromDN) {
                    $PoliciesAD[$GUIDFromDN] = 'Exists'
                } else {
                    $PoliciesAD[$GUIDFromDN] = 'Permissions issue'
                }
            }
        }
        Try {
            [Array]$GPOs = Get-GPO -All -Domain $Domain -Server $QueryServer
        } catch {
            Write-Warning "Get-GPOZaurrSysvol - Couldn't get GPOs from $Domain. Error: $($_.Exception.Message)"
            continue
        }
        if ($GPOs.Count -ge 2) {
            if (-not $VerifyDomainControllers) {
                Test-SysVolFolders -GPOs $GPOs -Server $Domain -Domain $Domain -PoliciesAD $PoliciesAD -PoliciesSearchBase $PoliciesSearchBase
            } else {
                foreach ($Server in $ForestInformation['DomainDomainControllers']["$Domain"]) {
                    Write-Verbose "Get-GPOZaurrSysvol - Processing $Domain \ $($Server.HostName.Trim())"
                    Test-SysVolFolders -GPOs $GPOs -Server $Server.Hostname -Domain $Domain -PoliciesAD $PoliciesAD -PoliciesSearchBase $PoliciesSearchBase
                }
            }
        } else {
            Write-Warning "Get-GPOZaurrSysvol - GPO count for $Domain is less then 2. This is not expected for fully functioning domain. Skipping processing SYSVOL folder."
        }
    }
}