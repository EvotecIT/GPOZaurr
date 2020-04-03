function Remove-GPOZaurr {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory)][validateset('Empty', 'Unlinked', 'EmptyAndUnlinked')][string] $Type,
        [int] $LimitProcessing,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [string[]] $GPOPath
    )
    $GPOs = Get-GPOZaurr -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation -GPOPath $GPOPath
    #$ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    $Count = 0
    $GPOSummary = foreach ($GPO in $GPOs) {
        #$QueryServer = $ForestInformation['QueryServers'][$GPO.Domain]['HostName'][0]
        if ($Type -eq 'Empty') {
            if ($GPO.ComputerSettingsAvailable -eq $false -and $GPO.UserSettingsAvailable -eq $false) {
                Write-Verbose "Remove-GPOZaurr - Removing GPO $($GPO.Name) from $($GPO.Domain)"
                $Count++
                Remove-GPO -Domain $GPO.Domain -Name $GPO.Name #-Server $QueryServer
                if ($LimitProcessing -eq $Count) {
                    break
                }
            }
        } elseif ($Type -eq 'EmptyAndUnlinked') {
            if ($GPO.ComputerSettingsAvailable -eq $false -and $GPO.UserSettingsAvailable -eq $false -or $Gpo.Linked -eq $false) {
                Write-Verbose "Remove-GPOZaurr - Removing GPO $($GPO.Name) from $($GPO.Domain)"
                $Count++
                Remove-GPO -Domain $GPO.Domain -Name $GPO.Name #-Server $QueryServer
                if ($LimitProcessing -eq $Count) {
                    break
                }
            }
        } elseif ($Type -eq 'Unlinked') {
            if ($Gpo.Linked -eq $false) {
                Write-Verbose "Remove-GPOZaurr - Removing GPO $($GPO.Name) from $($GPO.Domain)"
                $Count++
                Remove-GPO -Domain $GPO.Domain -Name $GPO.Name #-Server $QueryServer
                if ($LimitProcessing -eq $Count) {
                    break
                }
            }
        }
    }
    $GPOSummary
}