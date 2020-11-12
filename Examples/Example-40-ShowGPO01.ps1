Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Output = Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Type GPOOrphans -PassThru
$Output

Write-Color -Text 'Output of nested report' -Color DarkYellow -LinesBefore 1 -LinesAfter 1
$Output.GPOOrphans