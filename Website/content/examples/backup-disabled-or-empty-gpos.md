---
title: "Back up disabled or empty GPOs"
description: "Back up selected Group Policy Objects and verify the resulting backup set."
layout: docs
---

This example shows a practical starting point for cleaning up or reviewing older Group Policy environments before deeper remediation work.

It comes from the source example at `Examples/Example-01-BackupGPOs.ps1`.

## When to use this pattern

- You want to back up stale or disabled GPOs before any cleanup work.
- You need a quick inventory of what was actually exported.
- You want a repeatable backup step before broader Group Policy review.

## Example

```powershell
Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$GPOSummary = Backup-GPOZaurr `
    -BackupPath "$Env:UserProfile\Desktop\GPO" `
    -Verbose `
    -Type Disabled, Empty `
    -IncludeDomains 'ad.evotec.pl'

$GPOSummary | Format-Table -AutoSize

if ($GPOSummary) {
    Get-GPOZaurrBackupInformation -BackupFolder $GPOSummary[0].BackupDirectory | Format-Table -AutoSize
}
```

## What this demonstrates

- targeted GPO backup instead of exporting everything blindly
- focusing on disabled or empty policies first
- validating the produced backup set after the export

## Source

- [Example-01-BackupGPOs.ps1](https://github.com/EvotecIT/GPOZaurr/blob/master/Examples/Example-01-BackupGPOs.ps1)
