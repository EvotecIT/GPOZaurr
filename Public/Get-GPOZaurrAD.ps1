function Get-GPOZaurrAD {
    [cmdletbinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ParameterSetName = 'GPOName')]
        [string] $GPOName,

        [Parameter(ParameterSetName = 'GPOGUID')]
        [alias('GUID', 'GPOID')][string] $GPOGuid,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    Begin {
        $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    }
    Process {
        foreach ($Domain in $ForestInformation.Domains) {
            if ($PSCmdlet.ParameterSetName -eq 'GPOGUID') {
                if ($GPOGuid) {
                    if ($GPOGUID -notlike '*{*') {
                        $GUID = -join ("{", $GPOGUID, '}')
                    } else {
                        $GUID = $GPOGUID
                    }
                    $Splat = @{
                        Filter = "(objectClass -eq 'groupPolicyContainer') -and (Name -eq '$GUID')"
                        Server = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
                    }
                } else {
                    Write-Warning "Get-GPOZaurrAD - GPOGUID parameter is empty. Provide name and try again."
                    continue
                }
            } elseif ($PSCmdlet.ParameterSetName -eq 'GPOName') {
                if ($GPOName) {
                    $Splat = @{
                        Filter = "(objectClass -eq 'groupPolicyContainer') -and (DisplayName -eq '$GPOName')"
                        Server = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
                    }
                } else {
                    Write-Warning "Get-GPOZaurrAD - GPOName parameter is empty. Provide name and try again."
                    continue
                }
            } else {
                $Splat = @{
                    Filter = "(objectClass -eq 'groupPolicyContainer')"
                    Server = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
                }
            }
            Get-ADObject @Splat -Properties DisplayName, Name, Created, Modified, gPCFileSysPath, gPCFunctionalityVersion, gPCWQLFilter, gPCMachineExtensionNames, Description, CanonicalName, DistinguishedName | ForEach-Object -Process {
                $DomainCN = ConvertFrom-DistinguishedName -DistinguishedName $_.DistinguishedName -ToDomainCN
                $Output = [ordered]@{ }
                $Output['DisplayName'] = $_.DisplayName
                $Output['DomainName'] = $DomainCN
                $Output['Description'] = $_.Description
                $Output['GUID'] = $_.Name -replace '{' -replace '}'
                $Output['Path'] = $_.gPCFileSysPath
                $Output['FunctionalityVersion'] = $_.gPCFunctionalityVersion
                $Output['Created'] = $_.Created
                $Output['Modified'] = $_.Modified
                $Output['GPOCanonicalName'] = $_.CanonicalName
                $Output['GPODomainDistinguishedName'] = ConvertFrom-DistinguishedName -DistinguishedName $_.DistinguishedName -ToDC
                $Output['GPODistinguishedName'] = $_.DistinguishedName
                [PSCustomObject] $Output
            }
        }
    }
    End {

    }
}