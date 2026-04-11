---
title: "Find Group Policy permission issues"
description: "Use GPOZaurr to list permission problems that should be reviewed before cleanup or remediation."
layout: docs
---

This example is a practical first pass for environments where Group Policy permissions have changed over time and nobody is fully sure what still matches the intended model.

It comes from the source example at `Examples/Example-08-ListingPermissionIssues.ps1`.

## When to use this pattern

- You want to identify GPO permission problems before making changes.
- You need evidence for a cleanup or remediation plan.
- You want a small, repeatable report that can be reviewed by the directory operations team.

## Example

```powershell
Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

$Issues = Get-GPOZaurrPermissionIssue
$Issues | Format-Table -AutoSize
```

## What this demonstrates

- separating discovery from remediation
- getting a reviewable list of permission issues
- creating a safer starting point for Group Policy cleanup

## Source

- [Example-08-ListingPermissionIssues.ps1](https://github.com/EvotecIT/GPOZaurr/blob/master/Examples/Example-08-ListingPermissionIssues.ps1)
