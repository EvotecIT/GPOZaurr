function New-GPOZaurrExclusions {
    [cmdletBinding()]
    param(
        [Array] $ExclusionsArray,
        [ScriptBlock] $ExclusionsScriptBlock
    )

    if ($ExclusionsArray) {
        [string] $Code = @(
            '$Exclusions = @('
            [System.Environment]::NewLine
            foreach ($Exclusion in $ExclusionsArray) {
                "   `"$Exclusion`"" + [System.Environment]::NewLine
            }
            [System.Environment]::NewLine
            ')'
        )
        $Code
    } elseif ( $ExclusionsScriptBlock ) {
        throw "ExclusionsScriptBlock is not supported yet"
    } else {
        throw "ExclusionsArray or ExclusionsScriptBlock must be specified"
    }
}