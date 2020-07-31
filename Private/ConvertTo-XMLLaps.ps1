function ConvertTo-XMLLaps {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO
    )
    $CreateGPO = [ordered]@{
        DisplayName                                                  = $GPO.DisplayName
        DomainName                                                   = $GPO.DomainName
        GUID                                                         = $GPO.GUID
        GpoType                                                      = $GPO.GpoType
        #GpoCategory = $GPOEntry.GpoCategory
        #GpoSettings = $GPOEntry.GpoSettings
        'EnableLocalAdminPasswordManagement'                         = 'Not set'
        'PasswordSettings'                                           = 'Not set'
        'PasswordComplexity'                                         = $null
        'PasswordLength'                                             = $null
        'PasswordAge(Days)'                                          = $null
        'AdministratorAccountName'                                   = $null
        'NameOfAdministratorAccountToManage'                         = 'Not set'
        'DoNotAllowPasswordExpirationTimeLongerThanRequiredByPolicy' = 'Not set'
    }
    if ($GPO.DataSet.Category -eq 'LAPS') {
        foreach ($Policy in $GPO.DataSet) {
            if ($Policy.Category -eq 'LAPS') {
                foreach ($Setting in @('DropDownList', 'Numeric', 'EditText')) {
                    if ($Policy.$Setting) {
                        foreach ($Value in $Policy.$Setting) {
                            $Name = Format-ToTitleCase -Text $Value.Name -RemoveWhiteSpace
                            if ($Value.Value -is [string]) {
                                $CreateGPO["$Name"] = $Value.Value
                            } else {
                                $CreateGPO["$Name"] = $Value.Value.Name
                            }
                        }
                    }
                }
                $Name = (Format-ToTitleCase -Text $Policy.Name -RemoveWhiteSpace)
                $CreateGPO[$Name] = $Policy.State
            }
        }
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    }
}