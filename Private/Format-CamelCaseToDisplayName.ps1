function Format-CamelCaseToDisplayName {
    <#
    .SYNOPSIS
    Converts a camelCase string to a display name with spaces.

    .DESCRIPTION
    This function takes a camelCase string and converts it to a display name by adding spaces between words.

    .PARAMETER Text
    The camelCase string(s) to be converted to display name.

    .PARAMETER AddChar
    The character to add between words in the display name.

    .EXAMPLE
    Format-CamelCaseToDisplayName -Text 'testString' -AddChar ' '
    Converts 'testString' to 'Test String'

    .EXAMPLE
    Format-CamelCaseToDisplayName -Text 'anotherExample' -AddChar '-'
    Converts 'anotherExample' to 'Another-Example'
    #>
    [cmdletBinding()]
    param(
        [string[]] $Text,
        [string] $AddChar
    )
    foreach ($string in $Text) {
        $newString = ''
        $stringChars = $string.GetEnumerator()
        $charIndex = 0
        foreach ($char in $stringChars) {
            # If upper and not first character, add a space
            if ([char]::IsUpper($char) -eq 'True' -and $charIndex -gt 0) {
                $newString = $newString + $AddChar + $char.ToString()
            } elseif ($charIndex -eq 0) {
                # If the first character, make it a capital always
                $newString = $newString + $char.ToString().ToUpper()
            } else {
                $newString = $newString + $char.ToString()
            }
            $charIndex++
        }
        $newString
    }
}

#Format-CamelCaseToDisplayName -Text 'Test1', 'TestingMyAss', 'OtherTest', 'otherTEst'