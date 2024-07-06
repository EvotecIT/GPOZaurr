function Get-GPOZaurrFolders {
    <#
    .SYNOPSIS
    Retrieves information about GPO folders within specified domains.

    .DESCRIPTION
    This function retrieves information about various GPO folders within specified domains, such as PolicyDefinitions, Policies, Scripts, GPO Starters, NETLOGON Scripts, DfsrPrivate, and SYSVOL Root.

    .PARAMETER Type
    Specifies the type of folders to retrieve. Valid values are 'All', 'Netlogon', 'Sysvol'.

    .PARAMETER FolderType
    Specifies the type of folders to retrieve. Valid values are 'All', 'NTFRS', 'Empty'.

    .PARAMETER Forest
    Specifies the forest name to retrieve information for.

    .PARAMETER ExcludeDomains
    Specifies domains to exclude from the retrieval.

    .PARAMETER IncludeDomains
    Specifies domains to include in the retrieval.

    .PARAMETER ExtendedForestInformation
    Specifies additional information about the forest.

    .PARAMETER AsHashTable
    Indicates whether to return the output as a hashtable.

    .EXAMPLE
    Get-GPOZaurrFolders -Type All -FolderType All -Forest 'example.com' -IncludeDomains 'domain1', 'domain2' -ExcludeDomains 'domain3' -ExtendedForestInformation $info -AsHashTable
    Retrieves information about all types of GPO folders within the specified domains in the forest 'example.com', excluding 'domain3', and including 'domain1' and 'domain2', with extended forest information.

    .EXAMPLE
    Get-GPOZaurrFolders -Type Sysvol -FolderType NTFRS -Forest 'example.com' -IncludeDomains 'domain1' -AsHashTable
    Retrieves information about Sysvol folders using NTFRS type within the specified domain 'domain1' in the forest 'example.com' and returns the output as a hashtable.
    #>
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