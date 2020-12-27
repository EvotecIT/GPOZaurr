function Get-PrivGPOZaurrLink {
    [cmdletBinding()]
    param(
        [Microsoft.ActiveDirectory.Management.ADObject] $Object,
        [switch] $Limited,
        [System.Collections.IDictionary] $GPOCache
    )
    if ($Object.GpLink -and $Object.GpLink.Trim() -ne '') {
        $Object.GpLink -split '\]\[' | ForEach-Object -Process {
            $Link = $_ -replace '\[LDAP://' -replace '\]' -replace '\['
            if ($Link.Length -gt 10) {
                $SplitGPLink = $Link -split ';'
                $DN = $SplitGPLink[0]
                $Option = $SplitGPLink[1]
                if ($Option -eq '0') {
                    $Enforced = $false
                    $Enabled = $true
                } elseif ($Option -eq '1') {
                    $Enabled = $false
                    $Enforced = $false
                } elseif ($Option -eq '2') {
                    $Enabled = $true
                    $Enforced = $true
                } elseif ($Option -eq '3') {
                    $Enabled = $false
                    $Enforced = $true
                } else {
                    Write-Warning "Get-PrivGPOZaurrLink - This should't happen. Please investigate - Option: $Option"
                    $Enabled = $null
                    $Enforced = $null
                }
                $DomainCN = ConvertFrom-DistinguishedName -DistinguishedName $DN -ToDomainCN
                $Output = [ordered] @{
                    DistinguishedName = $Object.DistinguishedName
                    CanonicalName     = if ($Object.CanonicalName) { $Object.CanonicalName.TrimEnd('/') } else { $Object.CanonicalName }
                    Guid              = [Regex]::Match( $DN, '(?={)(.*)(?<=})').Value -replace '{' -replace '}'
                    Enforced          = $Enforced
                    Enabled           = $Enabled
                    ObjectClass       = $Object.ObjectClass
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
                        $Output['GPODomainDistinguishedName'] = ConvertFrom-DistinguishedName -DistinguishedName $DN -ToDC
                        $Output['GPODistinguishedName'] = $DN
                        [PSCustomObject] $Output
                    } else {
                        Write-Warning "Get-PrivGPOZaurrLink - Couldn't find link $Search in a GPO Cache. Lack of permissions for given GPO? Are you running as admin? Skipping."
                    }
                } else {
                    $Output['GPODomainDistinguishedName'] = ConvertFrom-DistinguishedName -DistinguishedName $DN -ToDC
                    $Output['GPODistinguishedName'] = $DN
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