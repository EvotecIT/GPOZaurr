function ConvertTo-TableFormat {
    <#
    .SYNOPSIS
        Rebuild an object based on the Format Data for the object.
    .DESCRIPTION
        Allows an object to be rebuilt based on the view data for the object. Uses Select-Object to create a new PSCustomObject.
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [Object]$InputObject
    )
    begin {
        $isFirst = $true
    }
    process {
        $format = if ($isFirst) {
            $formatData = Get-FormatData -TypeName $InputObject.PSTypeNames | Select-Object -First 1
            if ($formatData) {
                $viewDefinition = $formatData.FormatViewDefinition | Where-Object Control -match 'TableControl'

                for ($i = 0; $i -lt $viewDefinition.Control.Headers.Count; $i++) {
                    $name = $viewDefinition.Control.Headers[$i].Label

                    $displayEntry = $viewDefinition.Control.Rows.Columns[$i].DisplayEntry
                    if (-not $name) {
                        $name = $displayEntry.Value
                    }

                    $expression = switch ($displayEntry.ValueType) {
                        'Property' { $displayEntry.Value }
                        'ScriptBlock' { [ScriptBlock]::Create($displayEntry.Value) }
                    }

                    @{ Name = $name; Expression = $expression }
                }
            }
        }
        if ($format) {
            $InputObject | Select-Object -Property $format
        } else {
            $InputObject
        }
    }
}