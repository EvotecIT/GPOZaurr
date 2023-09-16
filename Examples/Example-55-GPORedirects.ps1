Import-Module .\GPoZaurr.psd1 -Force

$Data = Invoke-GPOZaurr -Online -FilePath $PSScriptRoot\Reports\GPOZaurr.html -Type GPORedirect -PassThru
$Data.GPORedirect