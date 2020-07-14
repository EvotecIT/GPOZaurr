function Get-GPOZaurrFiles {
    [cmdletbinding()]
    param(
        [ValidateSet('All', 'Netlogon', 'Sysvol')][string[]] $Type = 'All',
        [ValidateSet('None', 'MACTripleDES', 'MD5', 'RIPEMD160', 'SHA1', 'SHA256', 'SHA384', 'SHA512')][string] $HashAlgorithm = 'None',
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    $GPOCache = @{}
    $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    $GPOList = Get-GPOZaurrAD -ExtendedForestInformation $ForestInformation
    foreach ($GPO in $GPOList) {
        $GPOCache[$GPO.GUID] = $GPO
    }
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
        $Folders = @{
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
        }



        Get-ChildItem -Path $Path -ErrorAction SilentlyContinue -Recurse -ErrorVariable err -File | ForEach-Object {
            $BelongsToGPO = $false
            $GPODisplayName = $null
            $SuggestedAction = $null
            $FileType = foreach ($Key in $Folders.Keys) {
                if ($_.FullName -like "$Key*") {
                    $Folders[$Key]
                    break
                }
            }
            if ($FileType.Name -eq 'SYSVOL Policies') {
                $Test = $_.FullName -match '[\da-zA-Z]{8}-([\da-zA-Z]{4}-){3}[\da-zA-Z]{12}'
                if ($Test) {
                    $GPO = $GPOCache[$matches[0]]
                    if ($GPO) {
                        $BelongsToGPO = $true
                        $GPODisplayName = $GPO.DisplayName
                    }
                }
            }
            if ($_.Extension -eq '.adm') {
                $SuggestedAction = 'Delete legacy ADM file'
            } elseif ($_.Extension -in @('.admx', '.adml') -and $FileType.Name -eq 'SYSVOL PolicyDefinitions') {
                $SuggestedAction = 'Skip assesment'
            }


            $MetaData = Get-FileMetaData -File $_ -Signature #-HashAlgorithm $HashAlgorithm
            Add-Member -InputObject $MetaData -Name 'AssesmentType' -Value $FileType.Name -MemberType NoteProperty
            Add-Member -InputObject $MetaData -Name 'BelongsToGPO' -Value $BelongsToGPO -MemberType NoteProperty
            Add-Member -InputObject $MetaData -Name 'GPODisplayName' -Value $GPODisplayName -MemberType NoteProperty
            Add-Member -InputObject $MetaData -Name 'SuggestedAction' -Value $SuggestedAction -MemberType NoteProperty



            $MetaData
        }
        foreach ($e in $err) {
            Write-Warning "Get-GPOZaurrFiles - $($e.Exception.Message) ($($e.CategoryInfo.Reason))"
        }
    }
}

#Get-GPOZaurrFiles | ConvertTo-Excel -OpenWorkBook -FilePath $Env:USERPROFILE\GPOTesting.xlsx -ExcelWorkSheetName 'GPO Output' -AutoFilter -AutoFit -FreezeTopRowFirstColumn