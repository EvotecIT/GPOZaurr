<p align="center">
  <a href="https://www.powershellgallery.com/packages/GPOZaurr"><img src="https://img.shields.io/powershellgallery/v/GPOZaurr.svg"></a>
  <a href="https://www.powershellgallery.com/packages/GPOZaurr"><img src="https://img.shields.io/powershellgallery/vpre/GPOZaurr.svg?label=powershell%20gallery%20preview&colorB=yellow"></a>
  <a href="https://github.com/EvotecIT/GPOZaurr"><img src="https://img.shields.io/github/license/EvotecIT/GPOZaurr.svg"></a>
</p>

<p align="center">
  <a href="https://www.powershellgallery.com/packages/GPOZaurr"><img src="https://img.shields.io/powershellgallery/p/GPOZaurr.svg"></a>
  <a href="https://github.com/EvotecIT/GPOZaurr"><img src="https://img.shields.io/github/languages/top/evotecit/GPOZaurr.svg"></a>
  <a href="https://github.com/EvotecIT/GPOZaurr"><img src="https://img.shields.io/github/languages/code-size/evotecit/GPOZaurr.svg"></a>
  <a href="https://www.powershellgallery.com/packages/GPOZaurr"><img src="https://img.shields.io/powershellgallery/dt/GPOZaurr.svg"></a>
</p>

<p align="center">
  <a href="https://twitter.com/PrzemyslawKlys"><img src="https://img.shields.io/twitter/follow/PrzemyslawKlys.svg?label=Twitter%20%40PrzemyslawKlys&style=social"></a>
  <a href="https://evotec.xyz/hub"><img src="https://img.shields.io/badge/Blog-evotec.xyz-2A6496.svg"></a>
  <a href="https://www.linkedin.com/in/pklys"><img src="https://img.shields.io/badge/LinkedIn-pklys-0077B5.svg?logo=LinkedIn"></a>
</p>

# GPOZaurr

## Table of Contents

- [GPOZaurr](#gpozaurr)
  - [Table of Contents](#table-of-contents)
  - [Installing](#installing)
  - [Updating](#updating)
  - [Changelog](#changelog)

## Installing

GPOZaurr requires `RSAT` installed to provide results. If you don't have them you can install them as below. Keep in mind it also installs GUI tools so it shouldn't be installed on user workstations.

```powershell
# Windows 10 Latest
Add-WindowsCapability -Online -Name 'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0'
Add-WindowsCapability -Online -Name 'Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0'
```

Finally just install module:

```powershell
Install-Module -Name GPOZaurr -AllowClobber -Force
```

Force and AllowClobber aren't necessary, but they do skip errors in case some appear.

## Updating

```powershell
Update-Module -Name GPOZaurr
```

That's it. Whenever there's a new version, you run the command, and you can enjoy it. Remember that you may need to close, reopen PowerShell session if you have already used module before updating it.

**The essential thing** is if something works for you on production, keep using it till you test the new version on a test computer. I do changes that may not be big, but big enough that auto-update may break your code. For example, small rename to a parameter and your code stops working! Be responsible!

## Changelog

- 0.0.104 - 2021.01.04
  - [x] Improved `Get-GPOZaurrBrokenLink`
  - [x] Improved `Repair-GPOZaurrBrokenLink`
  - [x] Improved `Get-GPOZaurr`
    - [x] Added new report `GPOBrokenLink`
- 0.0.103 - 2021.01.04
  - [x] Improved `Get-GPOZaurr`
    - [x] Added new report `GPOBrokenLink`
  - [x] Added `Get-GPOZaurrBrokenLink`
  - [x] Added `Repair-GPOZaurrBrokenLink`
- 0.0.102 - 2021.01.02
  - [x] Improved `Get-GPOZaurrLink`
    - [x] Supports all links across forest
    - [x] Renamed Linked validate set from `Other` to `OrganizationalUnit`
  - [x] Improved `Get-GPOZaurrLinkSummary`
  - [x] Improved/BugFix `Get-GPOZaurr` to properly detect linked GPOs in sites/cross-domain
  - [x] Improved `Invoke-GPOZaurrPermission`
    - [x] Renamed Linked validate set from `Other` to `OrganizationalUnit`
  - [x] Improved `Invoke-GPOZaurr`
    - [x] Added `GPOLinks` basic list
- 0.0.101 - 23.12.2020
  - [x] Improved `Get-GPOZaurrBroken`
    - [x] It now detects `ObjectClass Issue`
    - [x] Heavily improved performance
    - [x] Removed some useless properties for this particular cmdlet
    - [x] All states: `Not available on SYSVOL`, `Not available in AD`, `Exists`, `Permissions Issue`, `ObjectClass Issue`
    - [x] Improved help
  - [x] Improved `Remove-GPOZaurrBroken`
    - [x] It now deals with `ObjectClass Issue`
    - [x] Heavily improved performance
    - [x] Removed some useless properties for this particular cmdlet
    - [x] Now requires manual type insert AD, SYSVOL or ObjectClass (or all of them). Before it was auto using AD/SYSVOL.
    - [x] Improved help
  - [x] Improved `Invoke-GPOZaurr`
    - [x] Type `GPOList`
    - [x] Renamed `GPOOrphans` to `GPOBroken`
    - [x] Improved `GPOBroken` with `ObjectClass issue`
- 0.0.100 - 21.12.2020
  - [x] Improved `Invoke-GPOZaurr`
    - [x] Type `GPOPermissionsRead`
    - [x] Type `GPOPermissions`
- 0.0.99 - 13.12.2020
  - [x] Improved `Invoke-GPOZaurr`
    - [x] Type `GPOList` - require GPO to be 7 days old for deletion to be proposed
    - [x] Type `GPOPermissions` - one stop for permissions
    - [x] Allows Steps to be chosen via their menu and out-of-order
  - [x] Improved `Remove-GPOZaurr` - added `RequireDays` parameter to prevent deletion of just modified GPOs
  - [x] Added `Get-GPOZaurrPermissionAnalysis`
  - [x] Added `Repair-GPOZaurrPermission`
- 0.0.98 - 10.12.2020
  - [x] Improved `Invoke-GPOZaurr`
    - [x] Type `GPOList` - fixed unexpected ending of cmdlet when error occurs (for example deleted GPO while script is running) which could impact results
    - [x] Other types - small color adjustment
  - [x] Fixed/Improved `Get-GPOZaurr` - fixed unexpected ending of cmdlet when error occurs (for example deleted GPO while script is running), improved code base
  - [x] Improved `Invoke-GPOZaurrSupport`
- 0.0.97 - 07.12.2020
  - [x] Improved `Invoke-GPOZaurr`
    - [x] Type `GPOList` - added more data, did small reorganization
- 0.0.96 - 07.12.2020
  - [x] Improved `Invoke-GPOZaurr`
    - [x] Type `GPOList` - added more data, added Optimization Step
  - [x] Added `Set-GPOZaurrStatus`
  - [x] Added `Optimize-GPOZaurr`
  - [x] Fixed `Invoke-GPOZaurrPermission` which would not remove permission due to internal changes earlier on
  - [x] Small change to `Backup-GPOZaurr`
    - [x] Added support for `Disabled`. It's now possbile to backup `All` (default), `Empty`,`Unlinked`,`Disabled` or a mix of them
    - [x] Removed useless `GPOPath` parameter
- 0.0.95 - 04.12.2020
  - [x] Fix for too big int - [#4](https://github.com/EvotecIT/GPOZaurr/issues/4) - tnx neztach
  - [x] Improved `Invoke-GPOZaurr`
    - [x] Type `GPOList` - added ability for Exclusions
    - [x] All other types, small improvements
    - [x] Added HideSteps, ShowError, ShowWarning -> Disabled Warnings/Errors by default as they tend to show too much information
  - [x] Improved `Remove-GPOZaurr` - added Exclusions
- 0.0.93 - 03.12.2020
  - [x] Improved `Invoke-GPOZaurr`
    - [x] Type `GPOList` reverted charts colors for entries to match colors
    - [ ] Added `Skip-GroupPolicy` to use within `Invoke-GPOZaurr`
  - [x] Improved `Invoke-GPOZaurr` with basic support for Exclusions
  - [x] Improved `Get-GPOZaurr` with basic support for Exclusions
  - [x] Improved `Remove-GPOZaurrPermission` error handling
- 0.0.92 - 01.12.2020
  - [x] Improved `Invoke-GPOZaurrSupport`
  - [x] Improved `Invoke-GPOZaurr`
    - [x] Type `GPOList` improved with more data, more problems and clearer information
  - [x] Improved `Remove-GPOZaurr`
    - [x] Added ability do remove disabed GPO
  - [x] Improved `Get-GPOZaurr` detecting more issues, delivering more data
- 0.0.91 - 24.11.2020
  - [x] Improves `Invoke-GPOZaurr` (WIP)
    - [x] Improve Type `GPOPermissionsUnknown`
- 0.0.90 - 23.11.2020
  - [x] Improves `Invoke-GPOZaurr` (WIP)
    - [x] Improves Type `GPODuplicates`
      - [x] Fix for chart color to be RED
    - [x] Add Type `GPOPermissionsUnknown`
    - [x] Improves logic for Data with 0/1 element
  - [x] Improves `Remove-GPOZaurrDuplicateObject` - removed `Confirm` requirement
  - [x] Improves `Get-GPOZaurrNetLogon` with more verbose
  - [x] Improves `Repair-GPOZaurrNetLogonOwner` with more verbose and fix for `LimitProcessing`
- 0.0.89 - 22.11.2020
  - [x] Small update `Add-GPOZaurrPermission`
  - [x] Improves `Invoke-GPOZaurr` (WIP)
    - [x] Added Type `GPOPermissionsAdministrative`
- 0.0.88 - 18.11.2020
  - [x] Fix for `Add-GPOZaurrPermission`
- 0.0.87 - 18.11.2020
  - [x] Improve error handling `Remove-GPOZaurrBroken`
- 0.0.86 - 18.11.2020
  - [x] Improve error handling `Remove-GPOZaurrBroken`
- 0.0.85 - 17.11.2020
  - [x] Improves `Invoke-GPOZaurr` (WIP)
    - [x] Split `NetLogonPermissions` into `NetLogonPermissions` and `NetLogonOwners`
    - [x] Improved type `NetLogonPermissions`
    - [x] Improved type `NetLogonOwners`
  - [x] Improves `Get-GPOZaurrFiles`
  - [x] Improves `Get-GPOZaurrNetLogon`
  - [x] Fix for `Get-GPOZaurrNetLogon`
- 0.0.84 - 16.11.2020
  - [x] Improves `Invoke-GPOZaurr` (WIP)
    - [x] Type `NetLogonPermissions`
  - [x] Fix for `Get-GPOZaurrNetLogon`
- 0.0.83 - 14.11.2020
  - [x] Improves `Invoke-GPOZaurr` (WIP)
    - [x] Fix for wrong ActionRequired count
- 0.0.82 - 14.11.2020
  - [x] Added `Get-GPOZaurrPermissionIssue` to detect permission issue with no rights
  - [x] Improves `Invoke-GPOZaurr` (WIP)
    - [x] Type `GPOPermissionsRead` improved detection of problems with low permissions
- 0.0.81 - 12.11.2020
  - [x] Fix for `Set-GPOZaurrOwner` in case of missing permissions to not throw errors
  - [x] Improves `Invoke-GPOZaurr` (WIP)
    - [x] Type `GPOPermissionsRead` added
- 0.0.80 - 12.11.2020
  - [x] Improves `Invoke-GPOZaurr` (WIP)
    - [x] Type `GPOOrphans` clearer options, updated texts, split per domain
    - [x] Type `GPOOwners` clearer options, updated texts, split per domain
  - [x] Improves `Add-GPOZaurrPermission`
    - [x] Fixes LimitProcessing to work correctly
    - [x] Added `All` to process all GPOs
  - [x] Fixes `Remove-GPOZaurrPermission`
  - [x] Improves `Set-GPOZaurrOwner`
    - [x] Added `Force` to force `GPO Owner` to any principal (normally only Domain Admins)
- 0.0.79 - 10.11.2020
  - Improved `Invoke-GPOZaurr` - type `GPOOrphans`
- 0.0.78 - 10.11.2020
  - Improved `Remove-GPOZaurrBroken` more verbose
  - Improved `Get-GPOZaurrBroken` more verbose
  - Improved `Invoke-GPOZaurr` - type `GPOOrphans`
  - Improved `Invoke-GPOZaurr` - type `GPOList` - needs more work
  - Improved `Get-GPOZaurr` with better detection of Empty Policies (needs testing)
- 0.0.77 - 9.11.2020
  - Improved `Invoke-GPOZaurr` (WIP)
- 0.0.76 - 8.11.2020
  - Improved `Get-GPOZaurrNetLogon` to better handle errors
- 0.0.75 - 8.11.2020
  - Improved `Get-GPOZaurrPermissionConsistency` to stop checking consistency if path doesn't exists
- 0.0.74 - 8.11.2020
  - Improved `Invoke-GPOZaurr` (WIP)
- 0.0.73 - 7.11.2020
  - Improved `Invoke-GPOZaurr` (WIP)
  - Improved `Get-GPOZaurr`
- 0.0.72 - 6.11.2020
  - Improved `Invoke-GPOZaurr` (WIP)
- 0.0.71 - 3.11.2020
  - Improved `Invoke-GPOZaurr` (WIP)
- 0.0.70 - 29.10.2020
  - Added `Get-GPOZaurrDuplicateObject`
  - Added `Remove-GPOZaurrDuplicateObject`
- 0.0.69 - 29.10.2020
  - Improved `Invoke-GPOZaurr` (WIP)
  - Improved `Get-GPOZaurrNetLogon`
  - Improved `Get-GPOZaurrOwner`
  - Improved `Set-GPOZaurrOwner`
  - Added `Repair-GPOZaurrNetLogonOwner`
  - Improved `Invoke-GPOZaurr` (WIP)
- 0.0.68 - 28.10.2020
  - Renamed `Show-GPOZaurr` to `Invoke-GPOZaurr`
  - Renamed `Invoke-GPOZaurr` to `Invoke-GPOZaurrContent`
  - Improvements to `Get-GPOZaurrPermissionConsistency` - don't check for inherited permissions if top level ones are inconsistent
  - Improved `Invoke-GPOZaurr` (WIP)
- 0.0.67 - 22.10.2020
  - Improved `Show-GPOZaurr` (WIP)
- 0.0.66 - 22.10.2020
  - Improved `Show-GPOZaurr` (WIP)
- 0.0.65 - 22.10.2020
  - Improved `Show-GPOZaurr` (WIP)
- 0.0.64 - 21.10.2020
  - Renamed `Remove-GPOZaurrOrphaned` to `Remove-GPOZaurrBroken` keeping it as an alias
  - Renamed `Get-GPOZaurrSysvol` to `Get-GPOZaurrBroken` keeping it as an alias
  - Improved `Show-GPOZaurr` (WIP)
- 0.0.63 - 19.10.2020
  - Renamed `Invoke-GPOZaurrContent` back to `Invoke-GPOZaurr`
  - Added `Show-GPOZaurr` (WIP)
  - Added `OutputType`,`OutputType`,`Open`,`Online` parameters to `Invoke-GPOZaurr`
  - Added `Get-GPOZaurrNetLogon`
  - Improved `Get-GPOZaurrOwner`
  - Fixes `Get-GPOZaurrSysvol`
- 0.0.62 - 14.10.2020
  - Renamed `Invoke-GPOZaurr` to `Invoke-GPOZaurrContent` - I want to use `Invoke-GPOZaurr` for something else
  - Improvements to `Get-GPOZaurrPermissionConsistency` for GPOs without SYSVOL to be reported properly
  - Added `Get-GPOZaurrPermissionRoot`
  - Renamed `Remove-GPOZaurrOrphanedSysvolFolders` to `Remove-GPOZaurrOrphaned`
  - Improved `Remove-GPOZaurrOrphaned` to deal with orphaned folders but also orphaned AD GPO (No sysvol data)
  - Improved `Get-GPOZaurrSysVol` to detect orphaned SYSVOL or AD GPO objects
  - Improved `Get-GPOZaurrSysVol` to detect permissions issue when reading AD GPO objects
  - Added `Get-GPOZaurrPermissionRoot` to show which users/groups have control over all GPOs (allowed to create/modify)
  - Improved `Get-GPOZaurrPermissionSummary` to include `Get-GPOZaurrPermissionRoot` custom permissions
  - Updated `Remove-GPOZaurrPermission`
  - Updated `Get-GpoZaurrPermission`
  - Updated `Get-GPOZaurrFiles` to better handle access issue
  - Reversed parameters `Get-GPOZaurrFiles` from `Limited` to `ExtendedMetaData` and fixed missing columns
- 0.0.61 - 31.08.2020
  - Improvement to `Get-GPOZaurrPermissionSummary`
  - Fixes to `ConvertFrom-CSExtension`
  - Fixes to `Find-CSExtension`
- 0.0.59 - 26.08.2020
  - Improvement to `Get-GPOZaurrPermissionSummary`
- 0.0.58 - 26.08.2020
  - Improvement to `Get-GPOZaurrPermissionSummary`
- 0.0.57 - 26.08.2020
  - Improvement to `Get-GPOZaurrPermissionSummary`
- 0.0.56 - 26.08.2020
  - Added `Get-GPOZaurrPermissionSummary`
- 0.0.55 - 17.08.2020
  - Improved `Get-GPOZaurrInheritance`
- 0.0.54 - 16.08.2020
  - Added `Invoke-GPOZaurrSupport` (WIP)
  - Added `ConvertFrom-CSExtension`
  - Added `Find-CSExtension`
  - Added `Get-GPOZaurrInheritance`
- 0.0.53 - 16.08.2020
  - Bad release
- 0.0.52 - 16.08.2020
  - Bad release
- 0.0.51 - 2.08.2020
  - Updates to `Invoke-GPOZaurr` - still work in progress
  - Added `Get-GPOZaurrSysvolDFSR`
  - Added `Clear-GPOZaurrSysvolDFSR` (requires testing)
- 0.0.50 - 29.07.2020
  - Updates to couple of commands
- 0.0.49 - 23.07.2020
  - Hidden files were skipped - and people do crazy things with them
- 0.0.48 - 21.07.2020
  - Added `Get-GPOZaurrFilesPolicyDefinition`
  - Updates to `Invoke-GPOZaurr` - still work in progress
  - Updates to `Get-GPOZaurrFiles` - still work in progress
  - Updates to `Remove-GPOZaurrOrphanedSysvolFolders` with backup and support for domains
  - Module will now be signed
- 0.0.47 - 29.06.2020
  - Update to `Get-GPOZaurrAD` for better error reporting
  - Updates to `Invoke-GPOZaurr` - still work in progress
- 0.0.46 - 28.06.2020
  - Additional protection for `Get-GPOZaurrAD` for CNF duplicates
  - Update to `Save-GPOZaurrFiles`
  - Added `Invoke-GPOZaurr` (alias: `Find-GPO`) (heavy work in progress)
- 0.0.45 - 26.06.2020
  - During publishing ADEssentials required functions are now merged to prevent cyclic dependency bug [Using ModuleSpec syntax in RequiredModules causes incorrect "cyclic dependency" failures](https://github.com/PowerShell/PowerShell/issues/2607)
- 0.0.44 - 24.06.2020
  - Improvement to `Get-GPOZaurrLinkSummary`
- 0.0.43 - 21.06.2020
  - Added `Get-GPOZaurrFiles` to list files on NETLOGON/SYSVOL shares with a lot of details
- 0.0.42 - 19.06.2020
  - Fix for `Get-GPOZaurrLink` and `SearchBase` parameter
  - Fix for `Get-GPOZaurrLink` - canonical link Trim() throwing errors if empty
- 0.0.41 - 18.06.2020
  - Added paramerter `SkipDuplicates` to `Invoke-GPOZaurrPermission` which prevents applying permissions over and over again if 1 GPO is linked to a multiple OU's within another OU
- 0.0.40 - 18.06.2020
  - Fix for error `Get-GPOZaurrLink` - same issue as described on my [earlier blog - Get-ADObject : The server has returned the following error: invalid enumeration context.](https://evotec.xyz/get-adobject-the-server-has-returned-the-following-error-invalid-enumeration-context/).
    - `WARNING: Get-GPOZaurrLink - Processing error The server has returned the following error: invalid enumeration context.`
    - `WARNING: Get-GPOZaurrLink - Processing error A referral was returned from the server`
  - Added `SkipDuplicates` for `Get-GPOZaurrLink`
- 0.0.39 - 17.06.2020
  - Updates to `Invoke-GPOZaurrPermission` with new parameter `LimitAdministrativeGroupsToDomain`
    - This will get administrative based on IncludeDomains if given. It means that if GPO has Domain admins added from multiple domains it will only find one, and remove all other Domain Admins (if working with Domain Admins that is)
- 0.0.38 - 17.06.2020
  - Update to Get-PrivGPOZaurrLink which would cause problems to `Invoke-GPOZaurrPermission` if it would be run without Administrative permission and GPO wouldn't be accessible for that user
- 0.0.37 - 16.06.2020
  - Updates to `Invoke-GPOZaurrPermission` with new parameterset `Level`
  - Updates to `Get-GPOZaurrLinkSummary`
- 0.0.36 - 15.06.2020
  - Initial release
