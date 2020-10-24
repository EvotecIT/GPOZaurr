Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Asses GPO based on exported data
$Output = Invoke-GPOZaurrContent -GPOPath $Env:USERPROFILE\Desktop\GPOExport_2020.10.12 -Verbose -Type RegistrySetting
$Output | Format-Table *


# Export to Excel
foreach ($Key in $Output.Keys) {
    $Output[$Key] | ConvertTo-Excel -FilePath $Env:USERPROFILE\Desktop\EFGPOAnalysis.xlsx -ExcelWorkSheetName $Key -AutoFilter -AutoFit -FreezeTopRowFirstColumn
}
# Show the Excel
Start-Process "$Env:USERPROFILE\Desktop\EFGPOAnalysis.xlsx"

# Show HTML
New-HTML {
    New-HTMLTableOption -DataStore JavaScript
    foreach ($Key in $Output.Keys) {
        New-HTMLTab -Name $Key {
            New-HTMLTable -DataTable $Output[$Key] -Filtering -Title $Key
        }
    }
} -FilePath $Env:USERPROFILE\Desktop\EFGPOAnalysis.html -ShowHTML -Online