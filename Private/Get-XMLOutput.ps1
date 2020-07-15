function Get-XMLOutput {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [System.Xml.XmlElement[]] $GPOOutput,
        [string] $Splitter,
        [switch] $FullObjects
    )
    $LinksInformation = Get-LinksFromXML -GPOOutput $GPOOutput -Splitter $Splitter -FullObjects:$FullObjects
    foreach ($GpoType in @('User', 'Computer')) {
        if ($GPOOutput.$GpoType.ExtensionData.Extension) {
            foreach ($ExtensionType in $GPOOutput.$GpoType.ExtensionData.Extension) {
                # It's possible that one of the ExtensionType records has value null. Weird but happend.
                if ($ExtensionType) {
                    $GPOSettingTypeSplit = ($ExtensionType.type -split ':')
                    try {
                        $KeysToLoop = $ExtensionType | Get-Member -MemberType Properties -ErrorAction Stop | Where-Object { $_.Name -notin 'type', $GPOSettingTypeSplit[0] -and $_.Name -notin @('Blocked') }
                    } catch {
                        Write-Warning "Get-XMLStandard - things went sideways $($_.Exception.Message)"
                        continue
                    }
                    foreach ($GpoSettings in $KeysToLoop.Name) {
                        $Template = [ordered] @{
                            DisplayName = $GPO.DisplayName
                            DomainName  = $GPO.DomainName
                            GUID        = $GPO.Guid
                            GpoType     = $GpoType
                            GpoCategory = $GPOSettingTypeSplit[1]
                            GpoSettings = $GpoSettings
                        }
                        [PSCustomObject] $Template
                    }
                    continue

                    foreach ($GpoSettings in $KeysToLoop.Name) {
                        foreach ($Key in $ExtensionType.$GpoSettings) {
                            $Template = [ordered] @{
                                DisplayName = $GPO.DisplayName
                                DomainName  = $GPO.DomainName
                                GUID        = $GPO.Guid
                                GpoType     = $GpoType
                                GpoCategory = $GPOSettingTypeSplit[1]
                                GpoSettings = $GpoSettings
                            }
                            try {
                                $Properties = ($Key | Get-Member -MemberType Properties -ErrorAction Stop).Name
                            } catch {
                                Write-Warning "Get-XMLStandard - things went sideways 1 $($_.Exception.Message)"
                                $Properties = $null
                            }
                            foreach ($Property in $Properties) {
                                $Template["$Property"] = $Key.$Property
                            }
                            $Template['Linked'] = $LinksInformation.Linked
                            $Template['LinksCount'] = $LinksInformation.LinksCount
                            $Template['Links'] = $LinksInformation.Links
                            <#
                            $Template['IncludeComments'] = $GPOOutput.IncludeComments     # : true #: true
                            $Template['CreatedTime'] = $GPOOutput.CreatedTime         # : 2020-06-17T11:23:22 #: 2020-06-17T11:23:22
                            $Template['ModifiedTime'] = $GPOOutput.ModifiedTime        # : 2020-06-28T15:49:52 #: 2020-06-28T15:49:52
                            $Template['ReadTime'] = $GPOOutput.ReadTime            # : 2020-06-28T16:14:09.2209011Z #: 2020-06-28T16:14:09.2209011Z
                            $Template['SecurityDescriptor'] = $GPOOutput.SecurityDescriptor  # : SecurityDescriptor #: SecurityDescriptor
                            $Template['FilterDataAvailable'] = $GPOOutput.FilterDataAvailable # : true #: true
                            #>
                            [PSCustomObject] $Template
                        }
                    }
                }
            }
        }
    }
}