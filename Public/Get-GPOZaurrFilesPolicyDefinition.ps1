﻿function Get-GPOZaurrFilesPolicyDefinition {
    <#
    .SYNOPSIS
    Retrieves policy definitions for Group Policy Objects (GPOs) within specified domains.

    .DESCRIPTION
    This function retrieves policy definitions for GPOs within specified domains. It collects information about policy files, including their attributes and digital signatures.

    .PARAMETER Forest
    Specifies the forest name to retrieve GPO policy definitions from.

    .PARAMETER ExcludeDomains
    Specifies an array of domains to exclude from the search.

    .PARAMETER IncludeDomains
    Specifies an array of domains to include in the search.

    .PARAMETER ExtendedForestInformation
    Specifies additional forest information to include in the output.

    .PARAMETER Signature
    Indicates whether to retrieve digital signature information for policy files.

    .EXAMPLE
    Get-GPOZaurrFilesPolicyDefinition -Forest "contoso.com" -IncludeDomains "domain1", "domain2" -ExcludeDomains "domain3" -Signature
    Retrieves policy definitions for GPOs within the "contoso.com" forest, including domains "domain1" and "domain2" while excluding "domain3". Digital signature information is also retrieved.

    #>
    [alias('Get-GPOZaurrFilesPolicyDefinitions')]
    [cmdletbinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,

        [switch] $Signature
    )
    $Output = [ordered] @{
        FilesToDelete = [System.Collections.Generic.List[Object]]::new()
    }
    $ForestInformation = Get-WinADForestDetails -Extended -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    $FilesCache = @{}
    foreach ($Domain in $ForestInformation.Domains) {
        $Output[$Domain] = [ordered] @{}
        $FilesCache[$Domain] = [ordered] @{}
        $Directories = Get-ChildItem -Path "\\$Domain\SYSVOL\$Domain\policies\PolicyDefinitions" -Directory -ErrorAction SilentlyContinue -ErrorVariable err
        [Array] $Languages = foreach ($Directory in $Directories) {
            if ($Directory.BaseName.Length -eq 5) {
                $Directory.BaseName
            }
        }
        $Files = Get-ChildItem -Path "\\$Domain\SYSVOL\$Domain\policies\PolicyDefinitions" -ErrorAction SilentlyContinue -ErrorVariable +err -File #| Select-Object Name, FullName, CreationTime, LastWriteTime, Attributes
        foreach ($File in $Files) {
            $FilesCache[$Domain][$($File.BaseName)] = [ordered] @{
                Name           = $File.BaseName
                FullName       = $File.FullName
                IsReadOnly     = $File.IsReadOnly
                CreationTime   = $File.CreationTime
                LastAccessTime = $File.LastAccessTime
                LastWriteTime  = $File.LastWriteTime
                IsConsistent   = $false
            }
            foreach ($Language in $Languages) {
                $FilesCache[$Domain][$($File.BaseName)][$Language] = $false
            }
            if ($Signature) {
                $DigitalSignature = Get-AuthenticodeSignature -FilePath $File.FullName
                $FilesCache[$Domain][$($File.BaseName)]['SignatureStatus'] = $DigitalSignature.Status
                $FilesCache[$Domain][$($File.BaseName)]['SignatureCertificateSubject'] = $DigitalSignature.SignerCertificate.Subject
                $FilesCache[$Domain][$($File.BaseName)]['SignatureCertificateIssuer'] = $DigitalSignature.SignerCertificate.Issuer
                $FilesCache[$Domain][$($File.BaseName)]['SignatureCertificateSerialNumber'] = $DigitalSignature.SignerCertificate.SerialNumber
                $FilesCache[$Domain][$($File.BaseName)]['SignatureCertificateNotBefore'] = $DigitalSignature.SignerCertificate.NotBefore
                $FilesCache[$Domain][$($File.BaseName)]['SignatureCertificateNotAfter'] = $DigitalSignature.SignerCertificate.NotAfter
                $FilesCache[$Domain][$($File.BaseName)]['SignatureCertificateThumbprint'] = $DigitalSignature.SignerCertificate.Thumbprint
                $FilesCache[$Domain][$($File.BaseName)]['IsOSBinary'] = $DigitalSignature.IsOSBinary
            }
        }
        foreach ($Directory in $Directories) {
            $FilesLanguage = Get-ChildItem -Path $Directory.FullName -ErrorAction SilentlyContinue -ErrorVariable +err
            foreach ($FileLanguage in $FilesLanguage) {
                if ($FileLanguage.Extension -eq '.adml') {
                    if ($FilesCache[$Domain][$FileLanguage.BaseName]) {
                        $FilesCache[$Domain][$FileLanguage.BaseName][$Directory.Name] = $true
                    } else {
                        #Write-Warning "Get-GPOZaurrFilesPolicyDefinition - File $($FileLanguage.FullName) doesn't have a match."
                        $Output.FilesToDelete.Add(
                            [PSCustomobject] @{
                                Name           = $FileLanguage.BaseName
                                FullName       = $FileLanguage.FullName
                                IsReadOnly     = $FileLanguage.IsReadOnly
                                CreationTime   = $FileLanguage.CreationTime
                                LastAccessTime = $FileLanguage.LastAccessTime
                                LastWriteTime  = $FileLanguage.LastWriteTime
                            }
                        )
                    }
                } else {

                }
            }
        }

        foreach ($e in $err) {
            Write-Warning "Get-GPOZaurrLegacy - $($e.Exception.Message) ($($e.CategoryInfo.Reason))"
        }
        $ExcludeProperty = @(
            'Name', 'FullName', 'IsReadOnly', 'CreationTime', 'LastAccessTime', 'LastWriteTime', 'IsConsistent'
            'SignatureCertificateSubject', 'SignatureCertificateIssuer', 'SignatureCertificateSerialNumber', 'SignatureCertificateNotBefore'
            'SignatureCertificateNotAfter', 'SignatureCertificateThumbprint', 'SignatureStatus', 'IsOSBinary'
        )
        $Properties = Select-Properties -Objects $FilesCache[$Domain][0] -ExcludeProperty $ExcludeProperty
        $Output[$Domain] = foreach ($File in $FilesCache[$Domain].Keys) {
            $Values = foreach ($Property in $Properties) {
                $FilesCache[$Domain][$File][$Property]
            }
            if ($Values -notcontains $false) {
                $FilesCache[$Domain][$File]['IsConsistent'] = $true
            }
            [PSCustomObject] $FilesCache[$Domain][$File]
        }
    }
    $Output
}