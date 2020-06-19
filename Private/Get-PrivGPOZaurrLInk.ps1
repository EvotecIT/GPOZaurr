function Get-PrivGPOZaurrLink {
    [cmdletBinding()]
    param(
        [Microsoft.ActiveDirectory.Management.ADObject] $Object,
        [switch] $Limited,
        [System.Collections.IDictionary] $GPOCache
    )
    if ($Object.GpLink -and $Object.GpLink.Trim() -ne '') {
        #$Object.GpLink -split { $_ -eq '[' -or $_ -eq ']' } -replace ';0' -replace 'LDAP://'
        $Object.GpLink -split '\[LDAP://' -split ';' | ForEach-Object -Process {
            #Write-Verbose $_
            if ($_.Length -gt 10) {
                $DomainCN = ConvertFrom-DistinguishedName -DistinguishedName $_ -ToDomainCN
                $Output = [ordered] @{
                    DistinguishedName = $Object.DistinguishedName
                    CanonicalName     = if ($Object.CanonicalName) { $Object.CanonicalName.TrimEnd('/') } else { $Object.CanonicalName }
                    Guid              = [Regex]::Match( $_, '(?={)(.*)(?<=})').Value -replace '{' -replace '}'
                }
                $Search = -join ($DomainCN, $Output['Guid'])
                if ($GPOCache -and -not $Limited) {
                    if ($GPOCache[$Search]) {
                        $Output['DisplayName'] = $GPOCache[$Search].DisplayName
                        $Output['DomainName'] = $GPOCache[$Search].DomainName
                        $Output['Owner'] = $GPOCache[$Search].Owner
                        $Output['GpoStatus'] = $GPOCache[$Search].GpoStatus
                        $Output['Description'] = $GPOCache[$Search].Description
                        $Output['CreationTime'] = $GPOCache[$Search].CreationTime
                        $Output['ModificationTime'] = $GPOCache[$Search].ModificationTime
                        $Output['GPODomainDistinguishedName'] = ConvertFrom-DistinguishedName -DistinguishedName $_ -ToDC
                        $Output['GPODistinguishedName'] = $_
                        [PSCustomObject] $Output
                    } else {
                        Write-Warning "Get-PrivGPOZaurrLink - Couldn't find link $Search in a GPO Cache. Lack of permissions for given GPO? Are you running as admin? Skipping."
                    }
                } else {
                    $Output['GPODomainDistinguishedName'] = ConvertFrom-DistinguishedName -DistinguishedName $_ -ToDC
                    $Output['GPODistinguishedName'] = $_
                    [PSCustomObject] $Output
                }
            }
        }
    } elseif ($Object.LinkedGroupPolicyObjects -and $Object.LinkedGroupPolicyObjects.Trim() -ne '') {
        $Object.LinkedGroupPolicyObjects -split '\[LDAP://' -split ';' | ForEach-Object -Process {
            if ($_.Length -gt 10) {
                $DomainCN = ConvertFrom-DistinguishedName -DistinguishedName $_ -ToDomainCN
                $Output = [ordered] @{
                    DistinguishedName = $Object.DistinguishedName
                    CanonicalName     = if ($Object.CanonicalName) { $Object.CanonicalName.TrimEnd('/') } else { $Object.CanonicalName }
                    Guid              = [Regex]::Match( $_, '(?={)(.*)(?<=})').Value -replace '{' -replace '}'
                }
                $Search = -join ($DomainCN, $Output['Guid'])
                if ($GPOCache -and -not $Limited) {
                    if ($GPOCache[$Search]) {
                        $Output['Name'] = $GPOCache[$Search].DisplayName
                        $Output['DomainName'] = $GPOCache[$Search].DomainName
                        $Output['Owner'] = $GPOCache[$Search].Owner
                        $Output['GpoStatus'] = $GPOCache[$Search].GpoStatus
                        $Output['Description'] = $GPOCache[$Search].Description
                        $Output['CreationTime'] = $GPOCache[$Search].CreationTime
                        $Output['ModificationTime'] = $GPOCache[$Search].ModificationTime
                        $Output['GPODomainDistinguishedName'] = ConvertFrom-DistinguishedName -DistinguishedName $_ -ToDC
                        $Output['GPODistinguishedName'] = $_
                        [PSCustomObject] $Output
                    } else {
                        Write-Warning "Get-PrivGPOZaurrLink - Couldn't find link $Search in a GPO Cache. Lack of permissions for given GPO? Are you running as admin? Skipping."
                    }
                } else {
                    $Output['GPODomainDistinguishedName'] = ConvertFrom-DistinguishedName -DistinguishedName $_ -ToDC
                    $Output['GPODistinguishedName'] = $_
                    [PSCustomObject] $Output
                }
            }
        }
    }
}