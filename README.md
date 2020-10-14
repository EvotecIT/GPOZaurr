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

## To install

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

## And to update

```powershell
Update-Module -Name GPOZaurr
```

That's it. Whenever there's a new version, you run the command, and you can enjoy it. Remember that you may need to close, reopen PowerShell session if you have already used module before updating it.

**The essential thing** is if something works for you on production, keep using it till you test the new version on a test computer. I do changes that may not be big, but big enough that auto-update may break your code. For example, small rename to a parameter and your code stops working! Be responsible!

## Changelog

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
