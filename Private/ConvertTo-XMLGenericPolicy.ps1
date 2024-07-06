function ConvertTo-XMLGenericPolicy {
    <#
    .SYNOPSIS
    Converts a PowerShell custom object representing generic policy settings into XML format.

    .DESCRIPTION
    This function takes a PowerShell custom object representing generic policy settings and converts it into XML format for storage or transmission.

    .PARAMETER GPO
    The PowerShell custom object representing the generic policy settings.

    .PARAMETER Category
    An array of categories for the generic policy settings.

    .PARAMETER SingleObject
    Indicates whether to convert a single object or multiple objects.

    .EXAMPLE
    ConvertTo-XMLGenericPolicy -GPO $genericPolicyObject -Category @('Category1', 'Category2') -SingleObject

    Description:
    Converts the $genericPolicyObject into XML format for multiple categories as a single object.

    .EXAMPLE
    $genericPolicyObjects | ConvertTo-XMLGenericPolicy -Category @('Category1') -SingleObject

    Description:
    Converts multiple generic policy settings in $genericPolicyObjects into XML format for a single category.
    #>
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [string[]] $Category,
        [switch] $SingleObject
    )
    $UsedNames = [System.Collections.Generic.List[string]]::new()
    [Array] $Policies = foreach ($Cat in $Category) {
        $GPO.DataSet | Where-Object { $_.Category -like $Cat }
    }
    if ($Policies.Count -gt 0) {
        if ($SingleObject) {
            $CreateGPO = [ordered]@{
                DisplayName = $GPO.DisplayName
                DomainName  = $GPO.DomainName
                GUID        = $GPO.GUID
                GpoType     = $GPO.GpoType
                #GpoCategory = $GPOEntry.GpoCategory
                #GpoSettings = $GPOEntry.GpoSettings
                Count       = 0
                Settings    = $null
            }

            [Array] $CreateGPO['Settings'] = @(
                $Settings = [ordered] @{}
                foreach ($Policy in $Policies) {
                    #if ($Policy.Category -notlike $Category) {
                    # We check again for Category because one GPO can have multiple categories
                    # First check checks GPO globally,
                    #    continue
                    #}

                    $Name = Format-ToTitleCase -Text $Policy.Name -RemoveWhiteSpace -RemoveChar ',', '-', "'", '\(', '\)', ':'
                    $Settings[$Name] = $Policy.State

                    foreach ($Setting in @('DropDownList', 'Numeric', 'EditText', 'Text', 'CheckBox', 'ListBox')) {
                        if ($Policy.$Setting) {
                            foreach ($Value in $Policy.$Setting) {
                                if ($Value.Name) {
                                    $SubName = Format-ToTitleCase -Text $Value.Name -RemoveWhiteSpace -RemoveChar ',', '-', "'", '\(', '\)', ':'
                                    $SubName = -join ($Name, $SubName)
                                    if ($SubName -notin $UsedNames) {
                                        $UsedNames.Add($SubName)
                                    } else {
                                        $TimesUsed = $UsedNames | Group-Object | Where-Object { $_.Name -eq $SubName }
                                        $NumberToUse = $TimesUsed.Count + 1
                                        # We add same name 2nd and 3rd time to make sure we count properly
                                        $UsedNames.Add($SubName)
                                        # We now build property name based on amnount of times
                                        $SubName = -join ($SubName, "$NumberToUse")
                                    }
                                    if ($Value.Value -is [string]) {
                                        $Settings["$SubName"] = $Value.Value
                                    } elseif ($Value.Value -is [System.Xml.XmlElement]) {

                                        <#
                            if ($null -eq $Value.Value.Name) {
                                # Shouldn't happen but lets see
                                Write-Verbose $Value
                            } else {
                                $CreateGPO["$SubName"] = $Value.Value.Name
                            }

                            #>
                                        if ($Value.Value.Element) {
                                            $Settings["$SubName"] = $Value.Value.Element.Data -join '; '
                                        } elseif ($null -eq $Value.Value.Name) {
                                            # Shouldn't happen but lets see
                                            Write-Verbose "Tracking $Value"
                                        } else {
                                            $Settings["$SubName"] = $Value.Value.Name
                                        }

                                    } elseif ($Value.State) {
                                        $Settings["$SubName"] = $Value.State
                                    } elseif ($null -eq $Value.Value) {
                                        # This is most likely Setting 'Text
                                        # Do nothing, usually it's just a text to display
                                        #Write-Verbose "Skipping value for display because it's empty. Name: $($Value.Name)"
                                    } else {
                                        # shouldn't happen
                                        Write-Verbose $Value
                                    }
                                }
                            }
                        }
                    }


                }
                [PSCustomObject] $Settings
            )

            $CreateGPO['Count'] = $CreateGPO['Settings'].Count
            $CreateGPO['Linked'] = $GPO.Linked
            $CreateGPO['LinksCount'] = $GPO.LinksCount
            $CreateGPO['Links'] = $GPO.Links
            [PSCustomObject] $CreateGPO
        } else {

            $CreateGPO = [ordered]@{
                DisplayName = $GPO.DisplayName
                DomainName  = $GPO.DomainName
                GUID        = $GPO.GUID
                GpoType     = $GPO.GpoType
                #GpoCategory = $GPOEntry.GpoCategory
                #GpoSettings = $GPOEntry.GpoSettings
            }
            foreach ($Policy in $Policies) {
                #if ($Policy.Category -notlike $Category) {
                # We check again for Category because one GPO can have multiple categories
                # First check checks GPO globally,
                #    continue
                #}
                $Name = Format-ToTitleCase -Text $Policy.Name -RemoveWhiteSpace -RemoveChar ',', '-', "'", '\(', '\)', ':'
                $CreateGPO[$Name] = $Policy.State

                foreach ($Setting in @('DropDownList', 'Numeric', 'EditText', 'Text', 'CheckBox', 'ListBox')) {
                    if ($Policy.$Setting) {
                        foreach ($Value in $Policy.$Setting) {
                            if ($Value.Name) {
                                $SubName = Format-ToTitleCase -Text $Value.Name -RemoveWhiteSpace -RemoveChar ',', '-', "'", '\(', '\)', ':'
                                $SubName = -join ($Name, $SubName)
                                if ($SubName -notin $UsedNames) {
                                    $UsedNames.Add($SubName)
                                } else {
                                    $TimesUsed = $UsedNames | Group-Object | Where-Object { $_.Name -eq $SubName }
                                    $NumberToUse = $TimesUsed.Count + 1
                                    # We add same name 2nd and 3rd time to make sure we count properly
                                    $UsedNames.Add($SubName)
                                    # We now build property name based on amnount of times
                                    $SubName = -join ($SubName, "$NumberToUse")
                                }
                                if ($Value.Value -is [string]) {
                                    $CreateGPO["$SubName"] = $Value.Value
                                } elseif ($Value.Value -is [System.Xml.XmlElement]) {

                                    <#
                                if ($null -eq $Value.Value.Name) {
                                    # Shouldn't happen but lets see
                                    Write-Verbose $Value
                                } else {
                                    $CreateGPO["$SubName"] = $Value.Value.Name
                                }

                                #>
                                    if ($Value.Value.Element) {
                                        $CreateGPO["$SubName"] = $Value.Value.Element.Data -join '; '
                                    } elseif ($null -eq $Value.Value.Name) {
                                        # Shouldn't happen but lets see
                                        Write-Verbose "Tracking $Value"
                                    } else {
                                        $CreateGPO["$SubName"] = $Value.Value.Name
                                    }

                                } elseif ($Value.State) {
                                    $CreateGPO["$SubName"] = $Value.State
                                } elseif ($null -eq $Value.Value) {
                                    # This is most likely Setting 'Text
                                    # Do nothing, usually it's just a text to display
                                    #Write-Verbose "Skipping value for display because it's empty. Name: $($Value.Name)"
                                } else {
                                    # shouldn't happen
                                    Write-Verbose $Value
                                }
                            }
                        }
                    }
                }
            }
            $CreateGPO['Linked'] = $GPO.Linked
            $CreateGPO['LinksCount'] = $GPO.LinksCount
            $CreateGPO['Links'] = $GPO.Links
            [PSCustomObject] $CreateGPO
            #}
        }
    }
}