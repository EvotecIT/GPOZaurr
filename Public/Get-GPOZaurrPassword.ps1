function Get-GPOZaurrPassword {
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [string[]] $GPOPath
    )
    if (-not $GPOPath) {
        if (-not $ExtendedForestInformation) {
            $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains
        } else {
            $ForestInformation = $ExtendedForestInformation
        }

        [Array] $GPOPath = foreach ($Domain in $ForestInformation.Domains) {
            -join ('\\', $Domain, '\SYSVOL\', $Domain, '\Policies')
        }
    }
    if (-not $GPOPath) {
        return
    }
    foreach ($Path in $GPOPath) {
        #Extract the all XML files in the Folders
        $Items = Get-ChildItem -LiteralPath $Path -Recurse -Filter *.xml
        $Output = foreach ($XMLFileName in $Items) {
            #Convert XML in a String file
            [string]$XMLString = Get-Content ($XMLFileName.FullName)
            #Check if Cpassword Exist in the file
            if ($XMLString.Contains("cpassword")) {
                #Take the Cpassword Value from XML String file
                [string]$Cpassword = [regex]::matches($XMLString, '(cpassword=).+?(?=\")')
                $Cpassword = $Cpassword.split('(\")')[1]
                #Check if Cpassword has a value
                if ($Cpassword.Length -gt 20 -and $Cpassword -notlike '*cpassword*') {
                    $Mod = ($Cpassword.length % 4)
                    switch ($Mod) {
                        '1' { $Cpassword = $Cpassword.Substring(0, $Cpassword.Length - 1) }
                        '2' { $Cpassword += ('=' * (4 - $Mod)) }
                        '3' { $Cpassword += ('=' * (4 - $Mod)) }
                    }
                    $Base64Decoded = [Convert]::FromBase64String($Cpassword)
                    $AesObject = [System.Security.Cryptography.AesCryptoServiceProvider]::new()
                    #Use th AES Key
                    [Byte[]] $AesKey = @(0x4e, 0x99, 0x06, 0xe8, 0xfc, 0xb6, 0x6c, 0xc9, 0xfa, 0xf4, 0x93, 0x10, 0x62, 0x0f, 0xfe, 0xe8, 0xf4, 0x96, 0xe8, 0x06, 0xcc, 0x05, 0x79, 0x90, 0x20, 0x9b, 0x09, 0xa4, 0x33, 0xb6, 0x6c, 0x1b)
                    $AesIV = New-Object Byte[]($AesObject.IV.Length)
                    $AesObject.IV = $AesIV
                    $AesObject.Key = $AesKey
                    $DecryptorObject = $AesObject.CreateDecryptor()
                    [Byte[]] $OutBlock = $DecryptorObject.TransformFinalBlock($Base64Decoded, 0, $Base64Decoded.length)
                    #Convert Hash variable in a String valute
                    $Password = [System.Text.UnicodeEncoding]::Unicode.GetString($OutBlock)
                } else {
                    $Password = ''
                }
                #[string]$GPOguid = [regex]::matches($XMLFileName.DirectoryName, '(?<=\{).+?(?=\})')
                #$GPODetail = Get-GPO -guid $GPOguid
                [xml] $XMLContent = $XMLString

                #if (-not $XMLContent.gpo.Computer.ExtensionData.Extension.LocalUsersAndGroups.User.Properties.cpassword -and -not $XMLContent.gpo.User.ExtensionData.Extension.DriveMapSettings.Drive.Properties.cpassword) {
                #Write-Host ''
                #}
                if ($Password) {
                    $PasswordStatus = $true
                } else {
                    $PasswordStatus = $false
                }

                [PsCustomObject] @{
                    'Name'                              = $XMLContent.GPO.Name
                    'Links'                             = $XMLContent.GPO.LinksTo #| Select-Object -ExpandProperty SOMPath
                    'Enabled'                           = $XMLContent.GPO.GpoStatus
                    'PasswordStatus'                    = $PasswordStatus
                    #'GPO'                               = $XMLContent.gpo.Computer.ExtensionData.Extension.LocalUsersAndGroups
                    'User'                              = $XMLContent.gpo.Computer.ExtensionData.Extension.LocalUsersAndGroups.User.name
                    'Cpassword'                         = $XMLContent.gpo.Computer.ExtensionData.Extension.LocalUsersAndGroups.User.Properties.cpassword
                    'CpasswordMap'                      = $XMLContent.gpo.User.ExtensionData.Extension.DriveMapSettings.Drive.Properties.cpassword
                    'Password'                          = $Password
                    'GUID'                              = $XMLContent.GPO.Identifier.Identifier.InnerText

                    'Domain'                            = $XMLContent.GPO.Identifier.Domain

                    'ComputerSettingsAvailable'         = if ($null -eq $XMLContent.GPO.Computer.ExtensionData) { $false } else { $true }
                    'ComputerSettingsStatus'            = if ($XMLContent.GPO.Computer.VersionDirectory -eq 0 -and $XMLContent.GPO.Computer.VersionSysvol -eq 0) { "NeverModified" } else { "Modified" }
                    'ComputerEnabled'                   = [bool] $XMLContent.GPO.Computer.Enabled
                    'ComputerSetttingsVersionIdentical' = if ($XMLContent.GPO.Computer.VersionDirectory -eq $XMLContent.GPO.Computer.VersionSysvol) { $true } else { $false }
                    'ComputerSettings'                  = $XMLContent.GPO.Computer.ExtensionData.Extension

                    'UserSettingsAvailable'             = if ($null -eq $XMLContent.GPO.User.ExtensionData) { $false } else { $true }
                    'UserEnabled'                       = [bool] $XMLContent.GPO.User.Enabled
                    'UserSettingsStatus'                = if ($XMLContent.GPO.User.VersionDirectory -eq 0 -and $XMLContent.GPO.User.VersionSysvol -eq 0) { "NeverModified" } else { "Modified" }
                    'UserSettingsVersionIdentical'      = if ($XMLContent.GPO.User.VersionDirectory -eq $XMLContent.GPO.User.VersionSysvol) { $true } else { $false }
                    'UserSettings'                      = $XMLContent.GPO.User.ExtensionData.Extension


                    'CreationTime'                      = [DateTime] $XMLContent.GPO.CreatedTime
                    'ModificationTime'                  = [DateTime] $XMLContent.GPO.ModifiedTime
                    'ReadTime'                          = [DateTime] $XMLContent.GPO.ReadTime

                    'WMIFilter'                         = $GPO.WmiFilter.name
                    'WMIFilterDescription'              = $GPO.WmiFilter.Description
                    'Path'                              = $GPO.Path
                    #'SDDL'                      = if ($Splitter -ne '') { $XMLContent.GPO.SecurityDescriptor.SDDL.'#text' -join $Splitter } else { $XMLContent.GPO.SecurityDescriptor.SDDL.'#text' }
                    'ACL'                               = $XMLContent.GPO.SecurityDescriptor.Permissions.TrusteePermissions | ForEach-Object -Process {
                        [PSCustomObject] @{
                            'User'            = $_.trustee.name.'#Text'
                            'Permission Type' = $_.type.PermissionType
                            'Inherited'       = $_.Inherited
                            'Permissions'     = $_.Standard.GPOGroupedAccessEnum
                        }
                    }

                }
                #Write-Host "I find a Password [ " $Password " ] The GPO named:" $GPODetail" and th file is:" $XMLFileName

            } #if($XMLContent.Contains("cpassword")
        }
        $Output
    }
}