function Test-SysVolFolders {
    [cmdletBinding()]
    param(
        [Array] $GPOs,
        [string] $Server,
        [string] $Domain,
        [System.Collections.IDictionary] $PoliciesAD,
        [string] $PoliciesSearchBase
    )
    $Differences = @{ }
    $SysvolHash = @{ }
    $GPOGUIDS = ConvertFrom-DistinguishedName -DistinguishedName $GPOs.DistinguishedName
    $SysVolPath = "\\$($Server)\SYSVOL\$Domain\Policies"
    Write-Verbose "Get-GPOZaurrBroken - Processing SYSVOL from \\$($Server)\SYSVOL\$Domain\Policies"
    try {
        $SYSVOL = Get-ChildItem -Path "\\$($Server)\SYSVOL\$Domain\Policies" -Exclude 'PolicyDefinitions' -ErrorAction Stop -Verbose:$false
    } catch {
        $Sysvol = $Null
    }
    foreach ($_ in $SYSVOL) {
        $GUID = $_.Name
        $SysvolHash[$GUID] = $_
    }
    $Files = $SYSVOL.Name
    if ($Files) {
        $Comparing = Compare-Object -ReferenceObject $GPOGUIDS -DifferenceObject $Files -IncludeEqual
        foreach ($_ in $Comparing) {
            if ($_.InputObject -eq 'PolicyDefinitions') {
                # we skip policy definitions
                continue
            }
            $ADStatus = $PoliciesAD[$_.InputObject]
            if ($_.SideIndicator -eq '==') {
                #$Found = 'Exists'
                $Found = $ADStatus
            } elseif ($_.SideIndicator -eq '<=') {
                $Found = 'Not available on SYSVOL'
            } elseif ($_.SideIndicator -eq '=>') {
                if ($PoliciesAD[$_.InputObject]) {
                    $Found = $PoliciesAD[$_.InputObject]
                } else {
                    $Found = 'Not available in AD'
                }
            } else {
                # This shouldn't happen at all
                $Found = 'Orphaned GPO'
            }

            $Differences[$_.InputObject] = $Found
        }
    }
    $GPOSummary = @(
        $Count = 0
        foreach ($GPO in $GPOS) {
            $Count++
            $GPOGuid = ConvertFrom-DistinguishedName -DistinguishedName $GPO.DistinguishedName
            if ($GPO.DisplayName) {
                $GPODisplayName = $GPO.DisplayName
                $GPOName = $GPO.Name
                Write-Verbose "Get-GPOZaurrBroken - Processing [$($Domain)]($Count/$($GPOS.Count)) $($GPO.DisplayName)"
            } else {
                $GPOName = $GPOGuid
                $GPODisplayName = $GPOGuid
                Write-Verbose "Get-GPOZaurrBroken - Processing [$($Domain)]($Count/$($GPOS.Count)) $($GPOGuid)"
            }
            if ($null -ne $SysvolHash[$GPOGuid].FullName) {
                $FullPath = $SysvolHash[$GPOGuid].FullName
                $ErrorMessage = ''
            } else {
                $FullPath = -join ($SysVolPath, "\$($GPOGuid)")
                $ErrorMessage = 'Not found on SYSVOL'
            }
            if ($null -eq $Differences[$GPOGuid]) {
                $SysVolStatus = 'Unknown issue'
            } else {
                $SysVolStatus = $Differences[$GPOGuid]
            }
            [PSCustomObject] @{
                DisplayName       = $GPODisplayName
                Status            = $SysVolStatus
                DomainName        = $Domain
                SysvolServer      = $Server
                ObjectClass       = $GPO.ObjectClass
                Id                = $GPOName
                Path              = $FullPath
                DistinguishedName = -join ("CN=", $GPOGuid, ",", $PoliciesSearchBase)
                Description       = $GPO.Description
                CreationTime      = $GPO.Created
                ModificationTime  = $GPO.Modified
                Error             = $ErrorMessage
            }
        }
        # Now we need to list thru Sysvol files and fine those that do not exists as GPO and create dummy GPO objects to show orphaned gpos
        Write-Verbose "Get-GPOZaurrBroken - Processing SYSVOL differences"
        foreach ($_ in $Differences.Keys) {
            if ($Differences[$_] -in 'Not available in AD') {
                $FullPath = $SysvolHash[$_].FullName
                [PSCustomObject] @{
                    DisplayName       = $SysvolHash[$_].BaseName
                    Status            = $Differences[$_]
                    DomainName        = $Domain
                    SysvolServer      = $Server
                    ObjectClass       = ''
                    Id                = $_
                    Path              = $FullPath
                    DistinguishedName = -join ("CN=", $_, ",", $PoliciesSearchBase)
                    Description       = $null
                    CreationTime      = $SysvolHash[$_].CreationTime
                    ModificationTime  = $SysvolHash[$_].LastWriteTime
                    Error             = $ErrorMessage
                }
            }
        }
    )
    $GPOSummary | Sort-Object -Property DisplayName
}