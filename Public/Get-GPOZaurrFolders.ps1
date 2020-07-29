function Get-GPOZaurrFolders {
    [cmdletBinding()]
    param(
        [ValidateSet('All', 'Netlogon', 'Sysvol')][string[]] $Type = 'All',
        [ValidateSet('All', 'NTFRS', 'Empty')][string] $FolderType = 'All',
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [switch] $AsHashTable
    )
    $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    foreach ($Domain in $ForestInformation.Domains) {
        $Path = @(
            if ($Type -contains 'All') {
                "\\$Domain\SYSVOL\$Domain"
            }
            if ($Type -contains 'Sysvol') {
                "\\$Domain\SYSVOL\$Domain\policies"
            }
            if ($Type -contains 'NetLogon') {
                "\\$Domain\NETLOGON"
            }
        )
        # Order does matter
        $Folders = [ordered] @{
            "\\$Domain\SYSVOL\$Domain\policies\PolicyDefinitions" = @{
                Name = 'SYSVOL PolicyDefinitions'
            }
            "\\$Domain\SYSVOL\$Domain\policies"                   = @{
                Name = 'SYSVOL Policies'
            }
            "\\$Domain\SYSVOL\$Domain\scripts"                    = @{
                Name = 'NETLOGON Scripts'
            }
            "\\$Domain\SYSVOL\$Domain\StarterGPOs"                = @{
                Name = 'SYSVOL GPO Starters'
            }
            "\\$Domain\NETLOGON"                                  = @{
                Name = 'NETLOGON Scripts'
            }
            "\\$Domain\SYSVOL\$Domain\DfsrPrivate"                = @{
                Name = 'DfsrPrivate'
            }
            "\\$Domain\SYSVOL\$Domain"                            = @{
                Name = 'SYSVOL Root'
            }
        }
        $Exclusions = @{
            DfsrPrivate                = @{
                ConflictAndDeleted = $true
                Deleted            = $true
                Installing         = $true
            }
            'SYSVOL Policies'          = @{
                User    = $true
                Machine = $true
            }
            'NETLOGON Scripts'         = @{

            }
            'SYSVOL Root'              = @{

            }
            'SYSVOL GPO Starters'      = @{

            }
            'SYSVOL PolicyDefinitions' = @{

            }
        }

        Get-ChildItem -Path $Path -ErrorAction SilentlyContinue -Recurse -ErrorVariable +err -Force -Directory | ForEach-Object {
            $FileType = foreach ($Key in $Folders.Keys) {
                if ($_.FullName -like "$Key*") {
                    $Folders[$Key]
                    break
                }
            }
            $RootFolder = $Folders["$($_.FullName)"]
            if ($RootFolder) {
                $IsRootFolder = $true
            } else {
                $IsRootFolder = $false
            }

            $IsExcluded = $Exclusions["$($FileType.Name)"]["$($_.Name)"] -is [bool]
            if ($IsRootFolder -and $IsExcluded -eq $false) {
                $IsExcluded = $true
            }

            $FullFolder = Test-Path -Path "$($_.FullName)\*"
            $BrokenReplicationRoot = $_.Name -like '*_NTFRS_*'
            $BrokenReplicationChild = $_.FullName -like '*_NTFRS_*' -and $_.Name -notlike '*_NTFRS_*'
            $BrokenReplication = $_.FullName -like '*_NTFRS_*'

            $Object = [ordered] @{
                FolderType               = $FileType.Name
                FullName                 = $_.FullName
                IsEmptyFolder            = -not $FullFolder
                IsBrokenReplication      = $BrokenReplication
                IsBrokenReplicationRoot  = $BrokenReplicationRoot
                IsBrokenReplicationChild = $BrokenReplicationChild
                IsRootFolder             = $IsRootFolder
                IsExcluded               = $IsExcluded
                Name                     = $_.Name
                Root                     = $_.Root
                Parent                   = $_.Parent
                CreationTime             = $_.CreationTime
                LastWriteTime            = $_.LastWriteTime
                Attributes               = $_.Attributes
                DomainName               = $Domain
            }
            if (-not $Object.IsExcluded) {
                if ($FolderType -eq 'Empty' -and $Object.IsEmptyFolder -eq $true) {
                    if ($AsHashTable) {
                        $Object
                    } else {
                        [PSCustomObject] $Object
                    }
                } elseif ($FolderType -eq 'NTFRS' -and $Object.IsBrokenReplicationRoot -eq $true) {
                    if ($AsHashTable) {
                        $Object
                    } else {
                        [PSCustomObject] $Object
                    }
                } elseif ($FolderType -eq 'All') {
                    if ($AsHashTable) {
                        $Object
                    } else {
                        [PSCustomObject] $Object
                    }
                }
            }
        }
    }
    foreach ($e in $err) {
        Write-Warning "Get-GPOZaurrFolders - $($e.Exception.Message) ($($e.CategoryInfo.Reason))"
    }
}