function Get-GPOZaurrFiles {
    [cmdletbinding()]
    param(
        [ValidateSet('All', 'Netlogon', 'Sysvol')][string[]] $Type = 'All',
        [ValidateSet('None', 'MACTripleDES', 'MD5', 'RIPEMD160', 'SHA1', 'SHA256', 'SHA384', 'SHA512')][string] $HashAlgorithm = 'None',
        [switch] $Limited,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    $GPOCache = @{}
    $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    $GPOList = Get-GPOZaurrAD -ExtendedForestInformation $ForestInformation
    foreach ($GPO in $GPOList) {
        if (-not $GPOCache[$GPO.DomainName]) {
            $GPOCache[$GPO.DomainName] = @{}
        }
        $GPOCache[$($GPO.DomainName)][($GPO.GUID)] = $GPO
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
        }
        Get-ChildItem -Path $Path -ErrorAction SilentlyContinue -Recurse -ErrorVariable err -File | ForEach-Object {
            # Lets reset values just to be sure those are empty
            $GPO = $null
            $BelongsToGPO = $false
            $GPODisplayName = $null
            $SuggestedAction = $null
            $SuggestedActionComment = $null
            $FileType = foreach ($Key in $Folders.Keys) {
                if ($_.FullName -like "$Key*") {
                    $Folders[$Key]
                    break
                }
            }
            if ($FileType.Name -eq 'SYSVOL Policies') {
                $FoundGUID = $_.FullName -match '[\da-zA-Z]{8}-([\da-zA-Z]{4}-){3}[\da-zA-Z]{12}'
                if ($FoundGUID) {
                    $GPO = $GPOCache[$Domain][$matches[0]]
                    if ($GPO) {
                        $BelongsToGPO = $true
                        $GPODisplayName = $GPO.DisplayName
                    }
                }
                if ($GPO) {
                    $Correct = @(
                        [System.IO.Path]::Combine($GPO.Path, 'GPT.INI')
                        [System.IO.Path]::Combine($GPO.Path, 'GPO.cmt')
                        foreach ($TypeM in @('Machine', 'User')) {
                            [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\Registry\Registry.xml')
                            [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\Printers\Printers.xml')
                            [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Registry.pol')
                            [System.IO.Path]::Combine($GPO.Path, $TypeM, 'comment.cmtx')
                            [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\ScheduledTasks\ScheduledTasks.xml')
                            [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\Services\Services.xml')
                            [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\Groups\Groups.xml')

                            if ($_.Extension -eq '.aas') {
                                [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Applications', $_.Name)
                            }
                        }
                        [System.IO.Path]::Combine($GPO.Path, 'Machine\Microsoft\Windows NT\SecEdit\GptTmpl.inf')
                        [System.IO.Path]::Combine($GPO.Path, 'Machine\Microsoft\Windows NT\Audit\audit.csv')
                    )
                } else {
                    $Correct = @()
                }
                if ($_.FullName -in $Correct) {
                    $SuggestedAction = 'Skip assesment'
                    $SuggestedActionComment = 'Correctly placed in SYSVOL'
                } elseif ($_.Extension -eq '.adm') {
                    $SuggestedAction = 'Consider deleting'
                    $SuggestedActionComment = 'Most likely legacy ADM files'
                }
            } elseif ($FileType.Name -eq 'NETLOGON Scripts') {
                foreach ($Ext in @('*old*', '*bak*', '*bck')) {
                    if ($_.Extension -like $Ext) {
                        $SuggestedAction = 'Consider deleting'
                        $SuggestedActionComment = 'Most likely backup files'
                        break
                    }
                }
                if (-not $SuggestedAction) {
                    # We didn't find it in earlier check, lets go deeper
                    if ($_.Extension.Length -gt 5 -and $_.Extension -ne '.config') {
                        $SuggestedAction = 'Consider deleting'
                        $SuggestedActionComment = 'Extension longer then 5 chars'
                    } elseif ($_.Extension -eq '') {
                        $SuggestedAction = 'Consider deleting'
                        $SuggestedActionComment = 'No extension'
                    }
                }
                if (-not $SuggestedAction) {
                    foreach ($Name in @('*old*', '*bak*', '*bck*', '*Copy*')) {
                        if ($_.Name -like $Name) {
                            $SuggestedAction = 'Consider deleting'
                            $SuggestedActionComment = 'FileName contains backup related names'
                            break
                        }
                    }
                }
                if (-not $SuggestedAction) {
                    # We replace all letters leaving only numbers
                    # We want to find if there is a date possibly
                    $StrippedNumbers = $_.Name -replace "[^0-9]" , ''
                    if ($StrippedNumbers.Length -gt 5) {
                        $SuggestedAction = 'Consider deleting'
                        $SuggestedActionComment = 'FileName contains date related names'
                    }
                }
            } elseif ($FileType.Name -eq 'SYSVOL PolicyDefinitions') {
                if ($_.Extension -in @('.admx', '.adml')) {
                    $SuggestedAction = 'Skip assesment'
                    $SuggestedActionComment = 'Most likely ADMX templates'
                }
            } elseif ($FileType.Name -eq 'SYSVOL GPO Starters') {
                $FoundGUID = $_.FullName -match '[\da-zA-Z]{8}-([\da-zA-Z]{4}-){3}[\da-zA-Z]{12}'
                if ($FoundGUID) {
                    $GUID = $matches[0]
                    $TemporaryStarterPath = "\\$Domain\SYSVOL\$Domain\StarterGPOs\{$GUID}"
                    $Correct = @(
                        [System.IO.Path]::Combine($TemporaryStarterPath, 'StarterGPO.tmplx')
                        [System.IO.Path]::Combine($TemporaryStarterPath, 'en-US', 'StarterGPO.tmpll')
                        foreach ($TypeM in @('Machine', 'User')) {
                            [System.IO.Path]::Combine($TemporaryStarterPath, $TypeM, 'Registry.pol')
                            [System.IO.Path]::Combine($TemporaryStarterPath, $TypeM, 'comment.cmtx')
                        }
                    )
                    if ($_.FullName -in $Correct) {
                        $SuggestedAction = 'Skip assesment'
                        $SuggestedActionComment = 'Correctly placed in SYSVOL'
                    }
                }
            } else {

            }
            if (-not $SuggestedAction) {
                $SuggestedAction = 'Requires verification'
                $SuggestedActionComment = 'Not able to auto asses'
            }
            if ($Limited) {
                $MetaData = $_
            } else {
                $MetaData = Get-FileMetaData -File $_ -Signature #-HashAlgorithm $HashAlgorithm
            }
            Add-Member -InputObject $MetaData -Name 'AssesmentType' -Value $FileType.Name -MemberType NoteProperty
            Add-Member -InputObject $MetaData -Name 'BelongsToGPO' -Value $BelongsToGPO -MemberType NoteProperty
            Add-Member -InputObject $MetaData -Name 'GPODisplayName' -Value $GPODisplayName -MemberType NoteProperty
            Add-Member -InputObject $MetaData -Name 'SuggestedAction' -Value $SuggestedAction -MemberType NoteProperty
            Add-Member -InputObject $MetaData -Name 'SuggestedActionComment' -Value $SuggestedActionComment -MemberType NoteProperty

            if ($Limited) {
                $MetaData | Select-Object FullName, Name, Extension, SuggestedAction, SuggestedActionComment, AssesmentType, BelongsToGPO, GPODisplayName, IsReadOnly, CreationTime, LastAccessTime, LastWriteTime
            } else {
                $MetaData
            }
        }
        foreach ($e in $err) {
            Write-Warning "Get-GPOZaurrFiles - $($e.Exception.Message) ($($e.CategoryInfo.Reason))"
        }
    }
}

#Get-GPOZaurrFiles -Limited | ConvertTo-Excel -OpenWorkBook -FilePath $Env:USERPROFILE\GPOTesting.xlsx -ExcelWorkSheetName 'GPO Output' -AutoFilter -AutoFit -FreezeTopRowFirstColumn