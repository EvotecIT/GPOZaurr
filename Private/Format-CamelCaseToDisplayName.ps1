function Format-CamelCaseToDisplayName {
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