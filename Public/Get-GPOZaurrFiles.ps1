function Get-GPOZaurrFiles {
    <#
    .SYNOPSIS
    Retrieves information about Group Policy Objects (GPOs) stored in SYSVOL and NETLOGON folders.

    .DESCRIPTION
    This function retrieves information about GPOs stored in SYSVOL and NETLOGON folders of specified domains. It can filter by type of files and hash algorithms used for verification.

    .PARAMETER Type
    Specifies the type of files to retrieve. Valid values are 'All', 'Netlogon', and 'Sysvol'.

    .PARAMETER HashAlgorithm
    Specifies the hash algorithm to use for file verification. Valid values are 'None', 'MACTripleDES', 'MD5', 'RIPEMD160', 'SHA1', 'SHA256', 'SHA384', 'SHA512'.

    .PARAMETER Signature
    Indicates whether to include file signatures for verification.

    .PARAMETER AsHashTable
    Indicates whether to return the results as a hashtable.

    .PARAMETER Extended
    Indicates whether to include extended information about the forest.

    .PARAMETER ExtendedMetaData
    Indicates whether to include extended metadata information.

    .PARAMETER Forest
    Specifies the forest name to retrieve GPO information from.

    .PARAMETER ExcludeDomains
    Specifies an array of domains to exclude from the search.

    .PARAMETER IncludeDomains
    Specifies an array of domains to include in the search.

    .PARAMETER ExtendedForestInformation
    Specifies additional forest information to include.

    .EXAMPLE
    Get-GPOZaurrFiles -Type 'All' -HashAlgorithm 'SHA256' -Signature
    Retrieves all files from SYSVOL and NETLOGON folders with SHA256 hash algorithm and includes file signatures.

    .EXAMPLE
    Get-GPOZaurrFiles -Type 'Sysvol' -HashAlgorithm 'MD5' -AsHashTable
    Retrieves only SYSVOL files with MD5 hash algorithm and returns the results as a hashtable.
    #>
    [cmdletbinding()]
    param(
        [ValidateSet('All', 'Netlogon', 'Sysvol')][string[]] $Type = 'All',
        [ValidateSet('None', 'MACTripleDES', 'MD5', 'RIPEMD160', 'SHA1', 'SHA256', 'SHA384', 'SHA512')][string] $HashAlgorithm = 'None',
        [switch] $Signature,
        [switch] $AsHashTable,
        [switch] $Extended,
        [switch] $ExtendedMetaData,
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
            "\\$Domain\SYSVOL\$Domain\DfsrPrivate"                = @{
                Name = 'DfsrPrivate'
            }
            "\\$Domain\SYSVOL\$Domain"                            = @{
                Name = 'SYSVOL Root'
            }
        }
        Get-ChildItem -Path $Path -ErrorAction SilentlyContinue -Recurse -ErrorVariable err -File -Force | ForEach-Object {
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
                $Correct = @(
                    [System.IO.Path]::Combine($GPO.Path, 'GPT.INI')
                    [System.IO.Path]::Combine($GPO.Path, 'GPO.cmt')
                    [System.IO.Path]::Combine($GPO.Path, 'Group Policy', 'GPE.ini')
                    foreach ($TypeM in @('Machine', 'User')) {
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Registry.pol')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'comment.cmtx')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\Registry\Registry.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\Printers\Printers.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\ScheduledTasks\ScheduledTasks.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\Services\Services.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\Groups\Groups.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\RegionalOptions\RegionalOptions.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\FolderOptions\FolderOptions.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\Drives\Drives.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\InternetSettings\InternetSettings.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\Folders\Folders.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\PowerOptions\PowerOptions.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\Shortcuts\Shortcuts.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\Files\Files.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\EnvironmentVariables\EnvironmentVariables.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\NetworkOptions\NetworkOptions.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\DataSources\DataSources.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\NetworkShares\NetworkShares.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Preferences\StartMenuTaskbar\StartMenuTaskbar.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Applications\Microsoft\TBLayout.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Applications\Microsoft\DefaultApps.xml')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Applications\ADE.CFG')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Scripts\scripts.ini')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Scripts\psscripts.ini')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Documents & Settings\fdeploy.ini')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Documents & Settings\fdeploy1.ini')
                        [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Documents & Settings\fdeploy2.ini')
                        if ($_.Extension -eq '.aas') {
                            [System.IO.Path]::Combine($GPO.Path, $TypeM, 'Applications', $_.Name)
                        }
                    }
                    [System.IO.Path]::Combine($GPO.Path, 'Machine\Microsoft\Windows NT\SecEdit\GptTmpl.inf')
                    [System.IO.Path]::Combine($GPO.Path, 'Machine\Microsoft\Windows NT\Audit\audit.csv')
                )
                if ($GPO) {
                    if ($_.FullName -in $Correct) {
                        $SuggestedAction = 'Skip assesment'
                        $SuggestedActionComment = 'Correctly placed in SYSVOL'
                    } elseif ($_.FullName -like '*_NTFRS_*') {
                        $SuggestedAction = 'Consider deleting'
                        $SuggestedActionComment = 'Most likely replication error'
                    } elseif ($_.Extension -eq '.adm') {
                        $SuggestedAction = 'Consider deleting'
                        $SuggestedActionComment = 'Most likely legacy ADM files'
                    } elseif ($_.Name -eq 'Thumbs.db') {
                        $SuggestedAction = 'Consider deleting'
                        $SuggestedActionComment = 'Most likely database files to store image thumbnails on Windows systems.'
                    }
                    if (-not $SuggestedAction) {
                        $FullPathAdmFiles = [System.IO.Path]::Combine($GPO.Path, 'Adm\admfiles.ini')
                        if ($_.FullName -eq $FullPathAdmFiles) {
                            $SuggestedAction = 'Consider deleting'
                            $SuggestedActionComment = 'Most likely legacy ADM files settings file'
                        }
                    }
                    if (-not $SuggestedAction) {
                        foreach ($Ext in @('*old*', '*bak*', '*bck', '.new')) {
                            if ($_.Extension -like $Ext) {
                                $SuggestedAction = 'Consider deleting'
                                $SuggestedActionComment = 'Most likely backup files'
                                break
                            }
                        }
                    }
                    if (-not $SuggestedAction) {
                        <#
                        $IEAK = @(
                            'microsoft\IEAK\install.ins'
                            'MICROSOFT\IEAK\BRANDING\cs\connect.ras'
                            'microsoft\IEAK\BRANDING\cs\connect.set'
                            'microsoft\IEAK\BRANDING\cs\cs.dat'
                            'microsoft\IEAK\BRANDING\ADM\inetcorp.iem'
                            'microsoft\IEAK\BRANDING\ADM\inetcorp.inf'
                            'microsoft\IEAK\install.ins'
                            'microsoft\IEAK\BRANDING\favs\Outlook.ico'
                            'microsoft\IEAK\BRANDING\favs\Bio.ico'
                            'MICROSOFT\IEAK\BRANDING\favs\$fi380.ico'
                            'microsoft\IEAK\BRANDING\PROGRAMS\programs.inf'
                            'MICROSOFT\IEAK\BRANDING\RATINGS\ratings.inf'
                            'MICROSOFT\IEAK\BRANDING\RATINGS\ratrsop.inf'
                            'microsoft\IEAK\BRANDING\ZONES\seczones.inf'
                            'microsoft\IEAK\BRANDING\ZONES\seczrsop.inf'
                            'microsoft\IEAK\BRANDING\ZONES\seczrsop.inf'
                        )
                        #>
                        if ($_.FullName -like '*microsoft\IEAK*') {
                            # https://docs.microsoft.com/en-us/internet-explorer/ie11-deploy-guide/missing-internet-explorer-maintenance-settings-for-ie11#:~:text=The%20Internet%20Explorer%20Maintenance%20(IEM,Internet%20Explorer%2010%20or%20newer.
                            $SuggestedAction = 'GPO requires cleanup'
                            $SuggestedActionComment = 'Internet Explorer Maintenance (IEM) is deprecated for IE 11'
                        }
                    }
                } else {
                    <#
                    $FullPathAdmFiles = [System.IO.Path]::Combine($GPO.Path, 'Adm\admfiles.ini')
                    if ($_.FullName -in $Correct) {
                        $SuggestedAction = 'Consider deleting'
                        $SuggestedActionComment = 'Most likely orphaned SYSVOL GPO'
                    } elseif ($_.Extension -eq '.adm') {
                        $SuggestedAction = 'Consider deleting'
                        $SuggestedActionComment = 'Most likely orphaned SYSVOL GPO (legacy ADM files)'
                    } elseif ($_.FullName -eq $FullPathAdmFiles) {
                        $SuggestedAction = 'Consider deleting'
                        $SuggestedActionComment = 'Most likely orphaned SYSVOL GPO (legacy ADM files)'
                    }
                    #>
                    $SuggestedAction = 'Consider deleting'
                    $SuggestedActionComment = 'Most likely orphaned SYSVOL GPO'
                }
            } elseif ($FileType.Name -eq 'NETLOGON Scripts') {
                foreach ($Ext in @('*old*', '*bak*', '*bck', '.new')) {
                    if ($_.Extension -like $Ext) {
                        $SuggestedAction = 'Consider deleting'
                        $SuggestedActionComment = 'Most likely backup files'
                        break
                    }
                }
                if (-not $SuggestedAction) {
                    # We didn't find it in earlier check, lets go deeper
                    if ($_.Extension.Length -gt 6 -and $_.Extension -notin @('.config', '.sites', '.ipsec')) {
                        $SuggestedAction = 'Consider deleting'
                        $SuggestedActionComment = 'Extension longer then 5 chars'
                    } elseif ($_.Extension -eq '') {
                        $SuggestedAction = 'Consider deleting'
                        $SuggestedActionComment = 'No extension'
                    }
                }
                if (-not $SuggestedAction) {
                    foreach ($Name in @('*old*', '*bak*', '*bck*', '*Copy', '*backup*')) {
                        if ($_.BaseName -like $Name) {
                            $SuggestedAction = 'Consider deleting'
                            $SuggestedActionComment = "FileName contains backup related names ($Name)"
                            break
                        }
                    }
                }
                if (-not $SuggestedAction) {
                    if ($_.Name -eq 'Thumbs.db') {
                        $SuggestedAction = 'Consider deleting'
                        $SuggestedActionComment = 'Most likely database files to store image thumbnails on Windows systems.'
                    }
                }
                if (-not $SuggestedAction) {
                    foreach ($FullName in @('*backup*', '*Delete*', '*Obsoleet*', '*Obsolete*', '*Archive*')) {
                        if ($_.FullName -like $FullName) {
                            $SuggestedAction = 'Consider deleting'
                            $SuggestedActionComment = "Fullname contains backup related names ($FullName)"
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
                        $SuggestedActionComment = 'FileName contains over 5 numbers (date?)'
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
            if (-not $ExtendedMetaData) {
                $MetaData = [ordered] @{
                    LocationType           = $FileType.Name
                    FullName               = $_.FullName
                    #Name                   = $_.Name
                    Extension              = $_.Extension
                    SuggestedAction        = $SuggestedAction
                    SuggestedActionComment = $SuggestedActionComment
                    BelongsToGPO           = $BelongsToGPO
                    GPODisplayName         = $GPODisplayName
                    SizeMB                 = [math]::Round(($_.Length / 1MB), 2)
                    Size                   = $_.Length
                    Attributes             = $_.Attributes
                    CreationTime           = $_.CreationTime
                    LastAccessTime         = $_.LastAccessTime
                    LastWriteTime          = $_.LastWriteTime
                }
            } else {
                $MetaData = Get-FileMetaData -File $_ -AsHashTable
                $MetaData['SuggestedAction'] = $SuggestedAction
                $MetaData['SuggestedActionComment'] = $SuggestedActionComment
                $MetaData['BelongsToGPO'] = $BelongsToGPO
                $MetaData['GPODisplayName'] = $GPODisplayName
                $MetaData['SizeMB'] = [math]::Round(($_.Length / 1MB), 2)
                $MetaData['Size'] = $_.Length
            }
            if ($Signature) {
                try {
                    $DigitalSignature = Get-AuthenticodeSignature -FilePath $_.Fullname -ErrorAction Stop
                } catch {
                    Write-Warning "Get-GPOZaurrFiles - Error when reading signature: $($_.Exception.Message)"
                }
                if ($DigitalSignature) {
                    $MetaData['SignatureStatus'] = $DigitalSignature.Status
                    $MetaData['IsOSBinary'] = $DigitalSignature.IsOSBinary
                    $MetaData['SignatureCertificateSubject'] = $DigitalSignature.SignerCertificate.Subject
                    if ($Extended) {
                        $MetaData['SignatureCertificateIssuer'] = $DigitalSignature.SignerCertificate.Issuer
                        $MetaData['SignatureCertificateSerialNumber'] = $DigitalSignature.SignerCertificate.SerialNumber
                        $MetaData['SignatureCertificateNotBefore'] = $DigitalSignature.SignerCertificate.NotBefore
                        $MetaData['SignatureCertificateNotAfter'] = $DigitalSignature.SignerCertificate.NotAfter
                        $MetaData['SignatureCertificateThumbprint'] = $DigitalSignature.SignerCertificate.Thumbprint
                    }
                } else {
                    $MetaData['SignatureStatus'] = 'Not available'
                    $MetaData['IsOSBinary'] = $null
                    $MetaData['SignatureCertificateSubject'] = $null
                    if ($Extended) {
                        $MetaData['SignatureCertificateIssuer'] = $null
                        $MetaData['SignatureCertificateSerialNumber'] = $null
                        $MetaData['SignatureCertificateNotBefore'] = $null
                        $MetaData['SignatureCertificateNotAfter'] = $null
                        $MetaData['SignatureCertificateThumbprint'] = $null
                    }
                }
            }
            if ($HashAlgorithm -ne 'None') {
                $MetaData['ChecksumSHA256'] = (Get-FileHash -LiteralPath $_.FullName -Algorithm $HashAlgorithm).Hash
            }
            if ($AsHashTable) {
                $MetaData
            } else {
                [PSCustomObject] $MetaData
            }
        }
        foreach ($e in $err) {
            Write-Warning "Get-GPOZaurrFiles - $($e.Exception.Message) ($($e.CategoryInfo.Reason))"
        }
    }
}