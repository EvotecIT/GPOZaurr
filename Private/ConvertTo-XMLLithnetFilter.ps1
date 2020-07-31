function ConvertTo-XMLLithnetFilter {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [switch] $SingleObject
    )

    $CreateGPO = [ordered]@{
        DisplayName                                                                                                                = $GPO.DisplayName
        DomainName                                                                                                                 = $GPO.DomainName
        GUID                                                                                                                       = $GPO.GUID
        GpoType                                                                                                                    = $GPO.GpoType
        #GpoCategory = $GPOEntry.GpoCategory
        #GpoSettings = $GPOEntry.GpoSettings
        DisablePasswordFilter                                                                                                      = 'Not set' # : Disabled
        EnableLengthBasedComplexityRules                                                                                           = $null # : Enabled
        EnableLengthBasedComplexityRulesApplyTheFollowingRequirementsForPasswordsWithALengthLessThan                               = $null # : 9
        EnableLengthBasedComplexityRulesTotalNumberOfCharacterSetsRequiredNumberSymbolUppercaseLetterLowercaseLetter               = $null # : 4
        EnableLengthBasedComplexityRulesApplyTheFollowingRequirementsForPasswordsLongerThanTheFirstThresholdButWithALengthLessThan = $null # : 15
        EnableLengthBasedComplexityRulesTotalNumberOfCharacterSetsRequiredNumberSymbolUppercaseLetterLowercaseLetter2              = $null # : 4
        EnableLengthBasedComplexityRulesTotalNumberOfCharacterSetsRequiredNumberSymbolUppercaseLetterLowercaseLetter3              = $null # : 4
        #EnableLengthBasedComplexityRulesThresholdLevel1                                                                            = $null # :
        #EnableLengthBasedComplexityRulesAlternativelySpecifyTheExactCharacterSetsRequired                                          = $null # :
        #EnableLengthBasedComplexityRulesThresholdLevel2                                                                            = $null # :
        #EnableLengthBasedComplexityRulesAlternativelySpecifyTheExactCharacterSetsRequired2                                         = $null # :
        #EnableLengthBasedComplexityRulesThresholdLevel3                                                                            = $null # :
        #EnableLengthBasedComplexityRulesForPasswordsLongerThanTheSecondThresholdApplyTheFollowingRequirements                      = $null # :
        #EnableLengthBasedComplexityRulesAlternativelySpecifyTheExactCharacterSetsRequired3                                         = $null # :
        EnableLengthBasedComplexityRulesLowerCaseLetter                                                                            = 'Disabled' # :
        EnableLengthBasedComplexityRulesUpperCaseLetter                                                                            = 'Disabled' # :
        EnableLengthBasedComplexityRulesSymbol                                                                                     = 'Disabled' # :
        EnableLengthBasedComplexityRulesNumber                                                                                     = 'Disabled' # :
        EnableLengthBasedComplexityRulesNumberOrSymbol                                                                             = 'Disabled' # :
        EnableLengthBasedComplexityRulesLowerCaseLetter2                                                                           = 'Disabled' # :
        EnableLengthBasedComplexityRulesUpperCaseLetter2                                                                           = 'Disabled' # :
        EnableLengthBasedComplexityRulesSymbol2                                                                                    = 'Disabled' # :
        EnableLengthBasedComplexityRulesNumber2                                                                                    = 'Disabled' # :
        EnableLengthBasedComplexityRulesNumberOrSymbol2                                                                            = 'Disabled' # :
        EnableLengthBasedComplexityRulesLowerCaseLetter3                                                                           = 'Disabled' # :
        EnableLengthBasedComplexityRulesUpperCaseLetter3                                                                           = 'Disabled' # :
        EnableLengthBasedComplexityRulesSymbol3                                                                                    = 'Disabled' # :
        EnableLengthBasedComplexityRulesNumber3                                                                                    = 'Disabled' # :
        EnableLengthBasedComplexityRulesNumberOrSymbol3                                                                            = 'Disabled' # :
        MinimumPasswordLength                                                                                                      = $null # : Enabled
        MinimumPasswordLengthMinimumPasswordLength                                                                                 = $null # : 8
        PasswordsMustMatchASpecifiedRegularExpression                                                                              = $null # : Enabled
        PasswordsMustMatchASpecifiedRegularExpressionRegularExpression                                                             = $null # : sdf
        PasswordsMustMeetSpecifiedNumberOfComplexityPoints                                                                         = $null # : Enabled
        PasswordsMustMeetSpecifiedNumberOfComplexityPointsMinimumNumberOfPointsRequiredForPasswordToBeApproved                     = $null # : 13
        PasswordsMustMeetSpecifiedNumberOfComplexityPointsPointsForEachCharacterUsed                                               = $null # : 1
        PasswordsMustMeetSpecifiedNumberOfComplexityPointsPointsForEachNumberUsed                                                  = $null # : 0
        PasswordsMustMeetSpecifiedNumberOfComplexityPointsPointsForEachLowerCaseLetterUsed                                         = $null # : 0
        PasswordsMustMeetSpecifiedNumberOfComplexityPointsPointsForEachUpperCaseLetterUsed                                         = $null # : 0
        PasswordsMustMeetSpecifiedNumberOfComplexityPointsPointsPerSymbolUsed                                                      = $null # : 0
        PasswordsMustMeetSpecifiedNumberOfComplexityPointsPointsForTheUseOfAtLeastOneNumber                                        = $null # : 1
        PasswordsMustMeetSpecifiedNumberOfComplexityPointsPointsForTheUseOfAtLeastOneSymbol                                        = $null # : 2
        PasswordsMustMeetSpecifiedNumberOfComplexityPointsPointsForTheUseOfAtLeastOneUppercaseLetter                               = $null # : 1
        PasswordsMustMeetSpecifiedNumberOfComplexityPointsPointsForTheUseOfAtLeastOneLowercaseLetter                               = $null # : 0
        PasswordsMustNotMatchASpecifiedRegularExpression                                                                           = $null # : Enabled
        PasswordsMustNotMatchASpecifiedRegularExpressionRegularExpression                                                          = $null # : df
        RejectNormalizedPasswordsFoundInTheBannedWordStore                                                                         = $null # : Enabled
        RejectNormalizedPasswordsFoundInTheBannedWordStoreEnableForPasswordSetOperations                                           = $null # :
        RejectNormalizedPasswordsFoundInTheBannedWordStoreEnableForPasswordChangeOperations                                        = $null # :
        RejectNormalizedPasswordsFoundInTheCompromisedPasswordStore                                                                = $null # : Enabled
        RejectNormalizedPasswordsFoundInTheCompromisedPasswordStoreEnableForPasswordSetOperations                                  = $null # :
        RejectNormalizedPasswordsFoundInTheCompromisedPasswordStoreEnableForPasswordChangeOperations                               = $null # :
        RejectPasswordsFoundInTheCompromisedPasswordStore                                                                          = $null # : Enabled
        RejectPasswordsFoundInTheCompromisedPasswordStoreEnableForPasswordSetOperations                                            = $null # :
        RejectPasswordsFoundInTheCompromisedPasswordStoreEnableForPasswordChangeOperations                                         = $null # :
        RejectPasswordsThatContainTheUsersAccountName                                                                              = $null # : Enabled
        RejectPasswordsThatContainTheUsersDisplayName                                                                              = $null # : Enabled
    }
    $UsedNames = [System.Collections.Generic.List[string]]::new()
    if ($GPO.DataSet.Category -like 'Lithnet/Password Protection for Active Directory*') {
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