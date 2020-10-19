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

    $GPOGUIDS = $GPOs.ID.GUID
    $SysVolPath = "\\$($Server)\SYSVOL\$Domain\Policies"
    try {
        $SYSVOL = Get-ChildItem -Path "\\$($Server)\SYSVOL\$Domain\Policies" -Exclude 'PolicyDefinitions' -ErrorAction Stop
    } catch {
        $Sysvol = $Null
    }
    foreach ($_ in $SYSVOL) {
        $GUID = $_.Name -replace '{' -replace '}'
        $SysvolHash[$GUID] = $_
    }
    $Files = $SYSVOL.Name -replace '{' -replace '}'
    if ($Files) {
        $Comparing = Compare-Object -ReferenceObject $GPOGUIDS -DifferenceObject $Files -IncludeEqual
        foreach ($_ in $Comparing) {
            if ($_.InputObject -eq 'PolicyDefinitions') {
                # we skip policy definitions
                continue
            }
            if ($_.SideIndicator -eq '==') {
                $Found = 'Exists'
            } elseif ($_.SideIndicator -eq '<=') {
                $Found = 'Not available on SYSVOL'
            } elseif ($_.SideIndicator -eq '=>') {
                if ($PoliciesAD[$_.InputObject]) {
                    $Found = $PoliciesAD[$_.InputObject]
                } else {
                    $Found = 'Not available in AD'
                }
            } else {
                $Found = 'Orphaned GPO'
            }
            $Differences[$_.InputObject] = $Found
        }
    }
    $GPOSummary = @(
        foreach ($GPO in $GPOS) {
            if ($null -ne $SysvolHash[$GPO.Id.GUID].FullName) {
                $FullPath = $SysvolHash[$GPO.Id.GUID].FullName
                try {
                    $ACL = Get-Acl -Path $SysvolHash[$GPO.Id.GUID].FullName -ErrorAction Stop
                    $Owner = $ACL.Owner
                    $ErrorMessage = ''
                } catch {
                    Write-Warning "Get-GPOZaurrSysvol - ACL reading (1) failed for $FullPath with error: $($_.Exception.Message)"
                    $ACL = $null
                    $Owner = ''
                    $ErrorMessage = $_.Exception.Message
                }
            } else {
                $FullPath = -join ($SysVolPath, "\{$($GPO.Id.Guid)}")
                $ACL = $null
                $Owner = ''
                $ErrorMessage = 'Not found on SYSVOL'
            }
            if ($null -eq $Differences[$GPO.Id.Guid]) {
                $SysVolStatus = 'Unknown Issue'
            } else {
                $SysVolStatus = $Differences[$GPO.Id.Guid]
            }
            [PSCustomObject] @{
                DisplayName       = $GPO.DisplayName
                Status            = $SysVolStatus
                DomainName        = $GPO.DomainName
                SysvolServer      = $Server
                SysvolStatus      = $SysVolStatus
                GpoStatus         = $GPO.GpoStatus
                Owner             = $GPO.Owner
                FileOwner         = $Owner
                Id                = $GPO.Id.Guid
                Path              = $FullPath
                DistinguishedName = -join ("CN={", $GPO.Id.Guid, "},", $PoliciesSearchBase)
                Description       = $GPO.Description
                CreationTime      = $GPO.CreationTime
                ModificationTime  = $GPO.ModificationTime
                UserVersion       = $GPO.UserVersion
                ComputerVersion   = $GPO.ComputerVersion
                WmiFilter         = $GPO.WmiFilter
                Error             = $ErrorMessage
            }
        }
        # Now we need to list thru Sysvol files and fine those that do not exists as GPO and create dummy GPO objects to show orphaned gpos
        foreach ($_ in $Differences.Keys) {
            if ($Differences[$_] -in 'Not available in AD', 'Permissions issue') {
                $FullPath = $SysvolHash[$_].FullName
                try {
                    $ACL = Get-Acl -Path $FullPath -ErrorAction Stop
                    $Owner = $ACL.Owner
                    $ErrorMessage = ''
                } catch {
                    Write-Warning "Get-GPOZaurrSysvol - ACL reading (2) failed for $FullPath with error: $($_.Exception.Message)"
                    $ACL = $null
                    $Owner = $null
                    $ErrorMessage = $_.Exception.Message
                }

                [PSCustomObject] @{
                    DisplayName       = $SysvolHash[$_].BaseName
                    Status            = $Differences[$_]
                    DomainName        = $Domain
                    SysvolServer      = $Server
                    SysvolStatus      = 'Exists' #$Differences[$GPO.Id.Guid]
                    GpoStatus         = $Differences[$_]
                    Owner             = ''
                    FileOwner         = $Owner
                    Id                = $_
                    Path              = $FullPath
                    DistinguishedName = -join ("CN={", $_, "},", $PoliciesSearchBase)
                    Description       = $null
                    CreationTime      = $SysvolHash[$_].CreationTime
                    ModificationTime  = $SysvolHash[$_].LastWriteTime
                    UserVersion       = $null
                    ComputerVersion   = $null
                    WmiFilter         = $null
                    Error             = $ErrorMessage
                }
            }
        }
    )
    $GPOSummary | Sort-Object -Property DisplayName
}