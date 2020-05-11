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
            Get-ADObject @Splat -Properties DisplayName, Name, Created, Modified, gPCFileSysPath, gPCFunctionalityVersion, gPCWQLFilter, gPCMachineExtensionNames, Description, CanonicalName, DistinguishedName | ForEach-Object -Process { #, Deleted -IncludeDeletedObjects
                #if ($_) {
                $DomainCN = ConvertFrom-DistinguishedName -DistinguishedName $_.DistinguishedName -ToDomainCN
                $Output = [ordered]@{ }
                <#
                $Search = -join ($DomainCN, $Output['Guid'])
                if ($GPOCache -and -not $Limited) {
                    $Output['DisplayName'] = $GPOCache[$Search].DisplayName
                    $Output['DomainName'] = $GPOCache[$Search].DomainName
                    $Output['Owner'] = $GPOCache[$Search].Owner
                    $Output['GpoStatus'] = $GPOCache[$Search].GpoStatus
                    $Output['Description'] = $GPOCache[$Search].Description
                    $Output['CreationTime'] = $GPOCache[$Search].CreationTime
                    $Output['ModificationTime'] = $GPOCache[$Search].ModificationTime
                }
                #>
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

                <#
                    CanonicalName            : ad.evotec.xyz/System/Policies/{31B2F340-016D-11D2-945F-00C04FB984F9}
                    Created                  : 20.05.2018 09:55:29
                    Description              :
                    DisplayName              : Default Domain Policy
                    DistinguishedName        : CN={31B2F340-016D-11D2-945F-00C04FB984F9},CN=Policies,CN=System,DC=ad,DC=evotec,DC=xyz
                    gPCFileSysPath           : \\ad.evotec.xyz\sysvol\ad.evotec.xyz\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}
                    gPCFunctionalityVersion  : 2
                    gPCMachineExtensionNames : [{35378EAC-683F-11D2-A89A-00C04FBBCFA2}{53D6AB1B-2488-11D1-A28C-00C04FB94F17}][{827D319E-6EAC-11D2-A4EA-00C04F79F83A}{803E14A0-B4FB-11D0-A0D0-00A0C90F574B}][{B1BE8D72-6EAC-11D2-A4EA-00C04F79F83A}{53D6AB1B-2488-11D1-A28C-00C04FB94F17}]
                    Modified                 : 26.04.2020 18:53:56
                    Name                     : {31B2F340-016D-11D2-945F-00C04FB984F9}
                    ObjectClass              : groupPolicyContainer
                    ObjectGUID               : 679a6dd9-30fb-438c-a35f-e5fe8167703e
                    #>
                #}
            }
        }
    }
    End {

    }
}