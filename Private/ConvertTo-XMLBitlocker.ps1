function ConvertTo-XMLBitlocker {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO
    )
    $CreateGPO = [ordered]@{
        DisplayName = $GPO.DisplayName
        DomainName  = $GPO.DomainName
        GUID        = $GPO.GUID
        GpoType     = $GPO.GpoType
        #GpoCategory = $GPOEntry.GpoCategory
        #GpoSettings = $GPOEntry.GpoSettings
    }
    $UsedNames = [System.Collections.Generic.List[string]]::new()
    if ($GPO.DataSet.Category -like 'Windows Components/BitLocker Drive Encryption*') {
        foreach ($Policy in $GPO.DataSet) {
            $Name = Format-ToTitleCase -Text $Policy.Name -RemoveWhiteSpace -RemoveChars ',', '-', "'", '\(', '\)', ':'
            $CreateGPO[$Name] = $Policy.State

            foreach ($Setting in @('DropDownList', 'Numeric', 'EditText', 'Text', 'CheckBox')) {
                if ($Policy.$Setting) {
                    foreach ($Value in $Policy.$Setting) {
                        if ($Value.Name) {
                            $SubName = Format-ToTitleCase -Text $Value.Name -RemoveWhiteSpace -RemoveChars ',', '-', "'", '\(', '\)', ':'
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
                                if ($null -eq $Value.Value -and $CreateGPO["$SubName"]) {
                                    # if value is empty and we already have set value (such as Disabled) - we do nothing
                                } else {
                                    $CreateGPO["$SubName"] = $Value.Value
                                }
                            } elseif ($Value.State) {
                                $CreateGPO["$SubName"] = $Value.State

                            } elseif ($null -eq $Value.Value) {
                                # Do nothing, usually it's just a text to display
                                # Write-Verbose "Skipping value for display because it's empty. Name: $($Value.Name)"
                            } else {
                                if ($null -eq $Value.Value.Name -and $CreateGPO["$SubName"]) {
                                    # if value is empty and we already have set value (such as Disabled) - we do nothing
                                } else {
                                    $CreateGPO["$SubName"] = $Value.Value.Name
                                }
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
    }
}