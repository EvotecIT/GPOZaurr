Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

Get-GPOZaurrEmptyFolders | Where-Object { $_.Name -eq 'Adm' } | Format-Table *

Remove-GPOZaurrEmptyFolders -Folders Adm -Verbose -LimitProcessing 1