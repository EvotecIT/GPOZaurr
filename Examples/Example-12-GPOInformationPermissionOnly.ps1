Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$GPOS = Get-GPOZaurr -PermissionsOnly
# to screen
$GPOS | Format-Table -AutoSize
# to html
#$GPOS | Out-HtmlView
# to excel
#$GPOS | ConvertTo-Excel -FilePath $Env:UserProfile\Desktop\GPOExport.xlsx -ExcelWorkSheetName 'Permissions' -AutoFit -AutoFilter