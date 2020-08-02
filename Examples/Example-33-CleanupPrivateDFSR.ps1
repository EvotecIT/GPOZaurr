Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Cleanup based on https://techcommunity.microsoft.com/t5/ask-the-directory-services-team/manually-clearing-the-conflictanddeleted-folder-in-dfsr/ba-p/395711

# Get dfsr information
$DFSR = Get-GPOZaurrSysvolDFSR
$DFSR | Format-Table

# Cleanup DFSR Conflict Path
Clear-GPOZaurrSysvolDFSR -WhatIf