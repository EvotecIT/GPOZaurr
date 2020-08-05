Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

#Save-GPOZaurrFiles -GPOPath $ENV:USERPROFILE\Desktop\GPOExport -DeleteExisting
Save-GPOZaurrFiles -GPOPath 'C:\Support\GitHub\GpoZaurr\Ignore\GPOExportEvotec' #-DeleteExisting