function Test-SysVolFolders {
    [cmdletBinding()]
    param(
        [Array] $GPOs,
        [string] $Server,
        [string] $Domain
    )
    $Differences = @{ }
    $SysvolHash = @{ }

    $GPOGUIDS = $GPOs.ID.GUID
    try {
        $SYSVOL = Get-ChildItem -Path "\\$($Server)\SYSVOL\$Domain\Policies" -ErrorAction Stop
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
            if ($_.SideIndicator -eq '==') {
                $Found = 'Exists'
            } elseif ($_.SideIndicator -eq '<=') {
                $Found = 'Not available on SYSVOL'
            } elseif ($_.SideIndicator -eq '=>') {
                $Found = 'Orphaned GPO'
            } else {
                $Found = 'Orphaned GPO'
            }
            $Differences[$_.InputObject] = $Found
        }
    }
    $GPOSummary = @(
        foreach ($GPO in $GPOS) {
            if ($null -ne $SysvolHash[$GPO.Id.GUID].FullName) {
                try {
                    $ACL = Get-Acl -Path $SysvolHash[$GPO.Id.GUID].FullName -ErrorAction Stop
                } catch {
                    Write-Warning "Get-WinADGPOSysvolFolders - ACL reading failed for $($SysvolHash[$GPO.Id.GUID].FullName) with error: $($_.Exception.Message)"
                    $ACL = $null
                }
            } else {
                $ACL = $null
            }
            if ($null -eq $Differences[$GPO.Id.Guid]) {
                $SysVolStatus = 'Not available on SYSVOL'
            } else {
                $SysVolStatus = $Differences[$GPO.Id.Guid]
            }
            [PSCustomObject] @{
                DisplayName      = $GPO.DisplayName
                Status           = $Differences[$GPO.Id.Guid]
                DomainName       = $GPO.DomainName
                SysvolServer     = $Server
                SysvolStatus     = $SysVolStatus
                Owner            = $GPO.Owner
                FileOwner        = $ACL.Owner
                Id               = $GPO.Id.Guid
                GpoStatus        = $GPO.GpoStatus
                Description      = $GPO.Description
                CreationTime     = $GPO.CreationTime
                ModificationTime = $GPO.ModificationTime
                UserVersion      = $GPO.UserVersion
                ComputerVersion  = $GPO.ComputerVersion
                WmiFilter        = $GPO.WmiFilter
            }
        }
        # Now we need to list thru Sysvol files and fine those that do not exists as GPO and create dummy GPO objects to show orphaned gpos
        foreach ($_ in $Differences.Keys) {
            if ($Differences[$_] -eq 'Orphaned GPO') {
                if ($SysvolHash[$_].BaseName -notcontains 'PolicyDefinitions') {

                    if ($null -ne $SysvolHash[$_].FullName) {
                        $ACL = Get-Acl -Path $SysvolHash[$_].FullName -ErrorAction SilentlyContinue
                    } else {
                        $ACL = $null
                    }

                    [PSCustomObject] @{
                        DisplayName      = $SysvolHash[$_].BaseName
                        Status           = 'Orphaned GPO'
                        DomainName       = $Domain
                        SysvolServer     = $Server
                        SysvolStatus     = $Differences[$GPO.Id.Guid]
                        Owner            = $ACL.Owner
                        FileOwner        = $ACL.Owner
                        Id               = $_
                        GpoStatus        = 'Orphaned'
                        Description      = $null
                        CreationTime     = $SysvolHash[$_].CreationTime
                        ModificationTime = $SysvolHash[$_].LastWriteTime
                        UserVersion      = $null
                        ComputerVersion  = $null
                        WmiFilter        = $null
                    }
                }
            }
        }
    )
    $GPOSummary | Sort-Object -Property DisplayName
}