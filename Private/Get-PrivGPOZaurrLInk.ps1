function Get-PrivGPOZaurrLink {
    [cmdletBinding()]
    param(
        [Microsoft.ActiveDirectory.Management.ADObject] $Object,
        [switch] $Limited,
        [System.Collections.IDictionary] $GPOCache
    )
    if ($Object.GpLink -and $Object.GpLink.Trim() -ne '') {
        $Object.GpLink -split { $_ -eq '[' -or $_ -eq ']' } -replace ';0' -replace 'LDAP://' | ForEach-Object -Process {
            if ($_) {
                $Output = [ordered] @{
                    DistinguishedName = $Object.DistinguishedName
                    CanonicalName     = $Object.CanonicalName
                    Guid              = [Regex]::Match( $_, '(?={)(.*)(?<=})').Value -replace '{' -replace '}'
                }
                if ($GPOCache -and -not $Limited) {
                    $Output['DisplayName'] = $GPOCache[$Output['Guid']].DisplayName
                    $Output['DomainName'] = $GPOCache[$Output['Guid']].DomainName
                    $Output['Owner'] = $GPOCache[$Output['Guid']].Owner
                    $Output['GpoStatus'] = $GPOCache[$Output['Guid']].GpoStatus
                    $Output['Description'] = $GPOCache[$Output['Guid']].Description
                    $Output['CreationTime'] = $GPOCache[$Output['Guid']].CreationTime
                    $Output['ModificationTime'] = $GPOCache[$Output['Guid']].ModificationTime
                }
                $Output['GPODomainDistinguishedName'] = ConvertFrom-DistinguishedName -DistinguishedName $_ -ToDC
                $Output['GPODistinguishedName'] = $_
                [PSCustomObject] $Output
            }
        }
    } elseif ($Object.LinkedGroupPolicyObjects -and $Object.LinkedGroupPolicyObjects.Trim() -ne '') {
        $Object.LinkedGroupPolicyObjects -split { $_ -eq '[' -or $_ -eq ']' } -replace ';0' -replace 'LDAP://' | ForEach-Object -Process {
            if ($_) {
                $Output = [ordered] @{
                    DistinguishedName = $Object.DistinguishedName
                    CanonicalName     = $Object.CanonicalName
                    Guid              = [Regex]::Match( $_, '(?={)(.*)(?<=})').Value -replace '{' -replace '}'
                }
                if ($GPOCache -and -not $Limited) {
                    $Output['Name'] = $GPOCache[$Output['Guid']].DisplayName
                    $Output['DomainName'] = $GPOCache[$Output['Guid']].DomainName
                    $Output['Owner'] = $GPOCache[$Output['Guid']].Owner
                    $Output['GpoStatus'] = $GPOCache[$Output['Guid']].GpoStatus
                    $Output['Description'] = $GPOCache[$Output['Guid']].Description
                    $Output['CreationTime'] = $GPOCache[$Output['Guid']].CreationTime
                    $Output['ModificationTime'] = $GPOCache[$Output['Guid']].ModificationTime
                }
                $Output['GPODomainDistinguishedName'] = ConvertFrom-DistinguishedName -DistinguishedName $_ -ToDC
                $Output['GPODistinguishedName'] = $_
                [PSCustomObject] $Output
            }
        }
    }
}