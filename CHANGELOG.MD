# GPOZaurr Release History

## 0.0.152
  - ℹ️ Improved `Invoke-GPOZaurr` - disable deprecated reports if user doesn't ask for them but asks for all reports to be generated. Those reports are now disabled by default: GPOPermissionsAdministrative,GPOPermissionsRead,GPOPermissionsRoot,GPOPermissionsUnknown

## 0.0.151 - 2022.07.26
  - ℹ️ Improved `Invoke-GPOZaurr` by adding `SplitReports` functionality. This will allow you to split the reports into multiple files with a single request.
  - ℹ️ Improved `Get-GPOZaurrInheritance` with some error handling

## 0.0.150 - 2021.12.06
  - ℹ️ Improves `GPOUpdates` report from `Invoke-GPOZaurr` - additional property
## 0.0.149 - 2021.12.05
  - ℹ️ Improved docs
## 0.0.148 - 2021.12.05
  - ☑ Improved `Invoke-GPOZaurr` - type `GPOOrganizationalUnit` - excludes default redirected computers/users OUs [#30](https://github.com/EvotecIT/GPOZaurr/issues/30)
  - ☑ Improved `Get-GPOZaurrOrganizationalUnit` - excludes default redirected computers/users OUs as per [#30](https://github.com/EvotecIT/GPOZaurr/issues/30)
## 0.0.147 - 2021.12.03
  - 📃 Updates documentation
## 0.0.146 - 2021.11.02
  - ℹ️ Improves `GPOUpdates` report from `Invoke-GPOZaurr` - should be 7 days, not 14 days
## 0.0.145 - 2021.11.02
  - ℹ️ Improves `GPOUpdates` report from `Invoke-GPOZaurr` by fixing conditional formatting
## 0.0.144 - 2021.10.24
  - ℹ️ Improves `Get-GPOZaurrUpdates`
  - Adds `GPOUpdates` report to `Invoke-GPOZaurr`
## 0.0.143 - 2021.10.19
  - ℹ️ Improves `Get-GPOZaurrUpdates` with more verbose messages
## 0.0.142 - 2021.10.18
  - 🐛 Fixes `Get-GPOZaurrUpdates` when GPO is not linked
## 0.0.141 - 2021.10.17
  - 🛑 Removed property from `Get-GPOZaurrAD` - `FunctionalityVersion`
  - ➕ Added property to `Get-GPOZaurrAD` - `Owner`
  - ➕ Added ability to choose date ranges for `Get-GPOZaurrAD`
  - ➕ Added `Get-GPOZaurrUpdates` which shows last gpos added to forest
## 0.0.140 - 2021.08.24
  - ☑ Improved `Invoke-GPOZaurr` - type `GPOAnalysis` - added folder redirection type - [tnx PatrickOnGit](https://github.com/EvotecIT/GPOZaurr/pull/24)
## 0.0.139 - 2021.08.19
  - ☑ Improved `Invoke-GPOZaurr` - type `GPOOrganizationalUnit` - adding RootLevel information
## 0.0.138 - 2021.08.18
  - 🐛 Fix for exclusions using GUID with brackets for Invoke-GPOZaurr `GPOList` and related options
## 0.0.137 - 2021.08.17
  - ☑ Improved `Invoke-GPOZaurr` - type `GPOOrganizationalUnit` - moving delete of OU as non-mandatory option
## 0.0.136 - 2021.08.17
  - ☑ Improved wording
## 0.0.135 - 2021.08.17
  - ☑ Improved exclusions
## 0.0.134 - 2021.08.16
  - ☑ Improved exclusions for email use
## 0.0.133 - 2021.08.16
  - ☑ Improved exclusions for email use
## 0.0.132 - 2021.08.16
  - ☑ Improved exclusions for email use
## 0.0.131 - 2021.08.16
  - ☑ Improved exclusions for email use
## 0.0.130 - 2021.08.13
  - 💡 Updated HTML to new version of `PSWriteHTML` that fixes complains about `SearchBuilder` option
  - ☑ Improved `Invoke-GPOZaurr` - type `GPOOrganizationalUnit` with exclusions

    ```powershell
    Invoke-GPOZaurr -Type GPOOrganizationalUnit -Online -FilePath $PSScriptRoot\Reports\GPOZaurrOU.html -Exclusions @(
        '*OU=Production,DC=ad,DC=evotec,DC=pl'
        '*OU=Production,DC=ad,DC=evotec,DC=pl'
        '*DC=ad,DC=evotec,DC=pl'
    )
    ```

  - ☑ Improved `Get-GPOZaurrOrganizationalUnit` with exclusions

      ```powershell
      Get-GPOZaurrOrganizationalUnit -Verbose -ExcludeOrganizationalUnit @(
        '*,OU=Production,DC=ad,DC=evotec,DC=pl'
      ) | Format-Table
      ```

  - ☑ Improved `Remove-GPOZaurrLinkEmptyOU` with exclusions

    ```powershell
    $Exclude = @(
        "OU=Groups,OU=Production,DC=ad,DC=evotec,DC=pl"
        "OU=Test \, OU,OU=ITR02,DC=ad,DC=evotec,DC=xyz"
    )

    Remove-GPOZaurrLinkEmptyOU -Verbose -LimitProcessing 3 -WhatIf -ExcludeOrganizationalUnit $Exclude
    ```

  - ☑ Improved `Invoke-GPOZaurr` - type `GPOOwners` with exclusions

    ```powershell
    Invoke-GPOZaurr -FilePath $PSScriptRoot\Reports\GPOZaurrGPOOwners.html -Type GPOOwners -Online -Exclusions @(
        'EVOTEC\przemyslaw.klys'
    )
    ```

  - ☑ Improved `Set-GPOZaurrOwner` with exclusions/approved owners

    ```powershell
    Set-GPOZaurrOwner -Type All -Verbose -LimitProcessing 2 -WhatIf -IncludeDomains 'ad.evotec.xyz' -ApprovedOwner @(
        'EVOTEC\przemyslaw.klys'
    )
    ```

  - ☑ Improved `Get-GPOZaurrOwner` with exclusions/approved owners

    ```powershell
    $T = Get-GPOZaurrOwner -Verbose -IncludeSysvol -ApprovedOwner @('EVOTEC\przemyslaw.klys')
    $T | Format-Table *
    ```

  - ☑ Improved `Get-GPOZaurr` with exclusions and support for GUID, strings

    ```powershell
    $GPOS = Get-GPOZaurr -ExcludeGroupPolicies {
        Skip-GroupPolicy -Name 'de14_usr_std'
        Skip-GroupPolicy -Name 'de14_usr_std' -DomaiName 'ad.evotec.xyz'
        Skip-GroupPolicy -Name 'All | Trusted Websites' #-DomaiName 'ad.evotec.xyz'
        '{D39BF08A-87BF-4662-BFA0-E56240EBD5A2}'
        'COMPUTERS | Enable Sets'
    }
    $GPOS | Format-Table -AutoSize *
    ```

  - ☑ Improved `Invoke-GPOZaurr` with exclusions and support for GUID, strings

    ```powershell
    Invoke-GPOZaurr -Type GPOList -Exclusions {
        Skip-GroupPolicy -Name 'All | Trusted Websites' -DomaiName 'ad.evotec.xyz'
        '{D39BF08A-87BF-4662-BFA0-E56240EBD5A2}'
        'COMPUTERS | Enable Sets'
    }
    ```

## 0.0.129 - 2021.08.06
  - Added `Get-GPOZaurrOrganizationalUnit` and added `GPOOrganizationalUnit` in `Invoke-GPOZaurr` (preview)
  - Added `Remove-GPOZaurrLinkEmptyOU` which allows removing links from Empty OUs (preview)
  - Small update to parameter sets for `Set-GPOZaurrOwner`
## 0.0.128 - 2021.05.26
  - ☑ Improved `Invoke-GPOZaurrContent` - type `PublicKeyPoliciesCertificates` - added more certificate information
  - ☑ Improved `Invoke-GPOZaurr` - type `GPOAnalysis` - added more certificate information
## 0.0.128 Alpha 1 - 2021.05.17
  - 🐛 Fixes errors when normalizing properties [#17](https://github.com/EvotecIT/GPOZaurr/issues/17)
## 0.0.127 - 2021.04.15
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Report `GPOList` - moved description closer to statuses
  - ☑ Improved `Get-GPOZaurr` - moved description closer to statuses
## 0.0.126 - 2021.04.12
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Report `GPOBlockedInheritance` - hidden DistinguishedName, fixed some small typos
## 0.0.125 - 2021.04.11
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Report `GPOBlockedInheritance` - small fixes
## 0.0.124 - 2021.04.11
  - ☑ Added `SearchBuilder` to all tables
  - ☑ Automatically joins arrays in tables in `Invoke-GPOZaurr`
  - ☑ Improved `Get-GPOZaurrInheritance` with Exclusions and some help information
  - ☑ Improved `Invoke-GPOZaurr` with some Exclusions
  - ☑ Improved `Invoke-GPOZaurr`
    - 🔥 Report `GPOBlockedInheritance` - heavily improved functionality and data
## 0.0.123 - 2021.03.21
  - ☑ Fixes `Get-GPOZaurrLinkSummary`
## 0.0.122 - 2021.02.11
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Report `GPOAnalysis` - added `WindowsFirewallRules`,`WindowsFirewallProfiles`,`WindowsFirewallConnectionSecurityAuthentication`,`WindowsFirewallConnectionSecurityRules`
  - ☑ Improved `Invoke-GPOZaurrContent` as mentioned above for `GPOAnalysis`
## 0.0.121 - 2021.02.10
  - ☑ Improvement to `Get-GPOZaurr` - added description [#13](https://github.com/EvotecIT/GPOZaurr/issues/13)
  - ☑ Improvement to `Invoke-GPOZaurr -Type GPOList` - added description [#13](https://github.com/EvotecIT/GPOZaurr/issues/13)
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Report GPOAnalysis - added `FolderRedirection`
    - ☑ Report GPOAnalysis - renamed `FolderRedirection` to `FolderRedirectionPolicy`
  - ☑ Improved `Invoke-GPOZaurrContent` as mentioned above for `GPOAnalysis`
## 0.0.120 - 2021.02.10
  - ☑ Improvement to `Get-GPOZaurr` to warn if there is potential issue with EMPTY (which can happen on non-english system)
    - ☑ In such case GPOZaurr will asses EMPTY or not using old method which doesn't detect all EMPTY cases but shouldn't provide false positives
## 0.0.119
  - Broken release - weird
## 0.0.118 - 2021.02.09
  - ☑ Added information where the report is saved
  - ☑ Small improvement to `Get-GPOZaurr` to exlicitly define variable types
## 0.0.117 - 2021.02.09
  - ☑ Small fix to `Get-GPOZaurr` to exclude GPOList.xml which is used in offline mode by `Save-GPOZaurrFiles`
## 0.0.116 - 2021.02.08
  - ☑ Improved `Remove-GPOZaurrBroken` to handle ObjectClass problem, and removed reduntant check
## 0.0.115 - 2021.02.07
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ `GPOList` - clarified some texts, changed 7 days to 30 days as default
    - ☑ `NetLogonPermissions` - fixed missing text
  - ☑ Fixes `Get-GPOZaurrNetLogon` error on empty Owner - [#9](https://github.com/EvotecIT/GPOZaurr/issues/9)
## 0.0.114 - 2021.01.27
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ HTML now uses offline mode by default (no CDN) - increase in size of HTML up to 3MB
    - ☑ Using Online switch forces use of CDN - smaller files. For example `Invoke-GPOZaurr -Type GPOList -Online`
  - [ ] Improved `Invoke-GPOZaurrSupport`
    - ☑ HTML now uses offline mode by default (no CDN) - increase in size of HTML up to 3MB
    - ☑ Using Online switch forces use of CDN - smaller files. For example `Invoke-GPOZaurrSupport -Online`
    - ☑ Removed parameter Offline, added parameter Online
    - ☑ The cmdlet is not really production ready. It's work in progress
## 0.0.113 - 2021.01.25
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Report GPOAnalysis - added WindowsTimeService
  - ☑ Improved `Invoke-GPOZaurrContent`
    - ☑ Added `WindowsTimeService` type
## 0.0.112 - 2021.01.25
  - ☑ Improved `Invoke-GPOZaurr`
## 0.0.111 - 2021.01.24
  - ☑ Improved `Invoke-GPOZaurr`
## 0.0.110 - 2021.01.22
  - ☑ Improved `Invoke-GPOZaurr`
## 0.0.109 - 2021.01.11
  - ☑ Improved `Invoke-GPOZaurr`
## 0.0.108 - 2021.01.11
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Improved `GPOConsistency`
## 0.0.107 - 2021.01.11
  - ☑ Improved `Invoke-GPOZaurr`
## 0.0.106 - 2021.01.11
  - ☑ Improved `Invoke-GPOZaurrContent`
## 0.0.105 - 2021.01.05
  - ☑ Improved `Get-GPOZaurr`
    - ☑ Improved report `GPOBrokenLink`
## 0.0.104 - 2021.01.04
  - ☑ Improved `Get-GPOZaurrBrokenLink`
  - ☑ Improved `Repair-GPOZaurrBrokenLink`
  - ☑ Improved `Get-GPOZaurr`
    - ☑ Improved report `GPOBrokenLink`
## 0.0.103 - 2021.01.04
  - ☑ Improved `Get-GPOZaurr`
    - ☑ Added new report `GPOBrokenLink`
  - ☑ Added `Get-GPOZaurrBrokenLink`
  - ☑ Added `Repair-GPOZaurrBrokenLink`
## 0.0.102 - 2021.01.02
  - ☑ Improved `Get-GPOZaurrLink`
    - ☑ Supports all links across forest
    - ☑ Renamed Linked validate set from `Other` to `OrganizationalUnit`
  - ☑ Improved `Get-GPOZaurrLinkSummary`
  - ☑ Improved/BugFix `Get-GPOZaurr` to properly detect linked GPOs in sites/cross-domain
  - ☑ Improved `Invoke-GPOZaurrPermission`
    - ☑ Renamed Linked validate set from `Other` to `OrganizationalUnit`
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Added `GPOLinks` basic list
## 0.0.101 - 23.12.2020
  - ☑ Improved `Get-GPOZaurrBroken`
    - ☑ It now detects `ObjectClass Issue`
    - ☑ Heavily improved performance
    - ☑ Removed some useless properties for this particular cmdlet
    - ☑ All states: `Not available on SYSVOL`, `Not available in AD`, `Exists`, `Permissions Issue`, `ObjectClass Issue`
    - ☑ Improved help
  - ☑ Improved `Remove-GPOZaurrBroken`
    - ☑ It now deals with `ObjectClass Issue`
    - ☑ Heavily improved performance
    - ☑ Removed some useless properties for this particular cmdlet
    - ☑ Now requires manual type insert AD, SYSVOL or ObjectClass (or all of them). Before it was auto using AD/SYSVOL.
    - ☑ Improved help
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Type `GPOList`
    - ☑ Renamed `GPOOrphans` to `GPOBroken`
    - ☑ Improved `GPOBroken` with `ObjectClass issue`
## 0.0.100 - 21.12.2020
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Type `GPOPermissionsRead`
    - ☑ Type `GPOPermissions`
## 0.0.99 - 13.12.2020
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Type `GPOList` - require GPO to be 7 days old for deletion to be proposed
    - ☑ Type `GPOPermissions` - one stop for permissions
    - ☑ Allows Steps to be chosen via their menu and out-of-order
  - ☑ Improved `Remove-GPOZaurr` - added `RequireDays` parameter to prevent deletion of just modified GPOs
  - ☑ Added `Get-GPOZaurrPermissionAnalysis`
  - ☑ Added `Repair-GPOZaurrPermission`
## 0.0.98 - 10.12.2020
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Type `GPOList` - fixed unexpected ending of cmdlet when error occurs (for example deleted GPO while script is running) which could impact results
    - ☑ Other types - small color adjustment
  - ☑ Fixed/Improved `Get-GPOZaurr` - fixed unexpected ending of cmdlet when error occurs (for example deleted GPO while script is running), improved code base
  - ☑ Improved `Invoke-GPOZaurrSupport`
## 0.0.97 - 07.12.2020
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Type `GPOList` - added more data, did small reorganization
## 0.0.96 - 07.12.2020
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Type `GPOList` - added more data, added Optimization Step
  - ☑ Added `Set-GPOZaurrStatus`
  - ☑ Added `Optimize-GPOZaurr`
  - ☑ Fixed `Invoke-GPOZaurrPermission` which would not remove permission due to internal changes earlier on
  - ☑ Small change to `Backup-GPOZaurr`
    - ☑ Added support for `Disabled`. It's now possbile to backup `All` (default), `Empty`,`Unlinked`,`Disabled` or a mix of them
    - ☑ Removed useless `GPOPath` parameter
## 0.0.95 - 04.12.2020
  - ☑ Fix for too big int - [#4](https://github.com/EvotecIT/GPOZaurr/issues/4) - tnx neztach
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Type `GPOList` - added ability for Exclusions
    - ☑ All other types, small improvements
    - ☑ Added HideSteps, ShowError, ShowWarning -> Disabled Warnings/Errors by default as they tend to show too much information
  - ☑ Improved `Remove-GPOZaurr` - added Exclusions
## 0.0.93 - 03.12.2020
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Type `GPOList` reverted charts colors for entries to match colors
    - [ ] Added `Skip-GroupPolicy` to use within `Invoke-GPOZaurr`
  - ☑ Improved `Invoke-GPOZaurr` with basic support for Exclusions
  - ☑ Improved `Get-GPOZaurr` with basic support for Exclusions
  - ☑ Improved `Remove-GPOZaurrPermission` error handling
## 0.0.92 - 01.12.2020
  - ☑ Improved `Invoke-GPOZaurrSupport`
  - ☑ Improved `Invoke-GPOZaurr`
    - ☑ Type `GPOList` improved with more data, more problems and clearer information
  - ☑ Improved `Remove-GPOZaurr`
    - ☑ Added ability do remove disabed GPO
  - ☑ Improved `Get-GPOZaurr` detecting more issues, delivering more data
## 0.0.91 - 24.11.2020
  - ☑ Improves `Invoke-GPOZaurr` (WIP)
    - ☑ Improve Type `GPOPermissionsUnknown`
## 0.0.90 - 23.11.2020
  - ☑ Improves `Invoke-GPOZaurr` (WIP)
    - ☑ Improves Type `GPODuplicates`
      - ☑ Fix for chart color to be RED
    - ☑ Add Type `GPOPermissionsUnknown`
    - ☑ Improves logic for Data with 0/1 element
  - ☑ Improves `Remove-GPOZaurrDuplicateObject` - removed `Confirm` requirement
  - ☑ Improves `Get-GPOZaurrNetLogon` with more verbose
  - ☑ Improves `Repair-GPOZaurrNetLogonOwner` with more verbose and fix for `LimitProcessing`
## 0.0.89 - 22.11.2020
  - ☑ Small update `Add-GPOZaurrPermission`
  - ☑ Improves `Invoke-GPOZaurr` (WIP)
    - ☑ Added Type `GPOPermissionsAdministrative`
## 0.0.88 - 18.11.2020
  - ☑ Fix for `Add-GPOZaurrPermission`
## 0.0.87 - 18.11.2020
  - ☑ Improve error handling `Remove-GPOZaurrBroken`
## 0.0.86 - 18.11.2020
  - ☑ Improve error handling `Remove-GPOZaurrBroken`
## 0.0.85 - 17.11.2020
  - ☑ Improves `Invoke-GPOZaurr` (WIP)
    - ☑ Split `NetLogonPermissions` into `NetLogonPermissions` and `NetLogonOwners`
    - ☑ Improved type `NetLogonPermissions`
    - ☑ Improved type `NetLogonOwners`
  - ☑ Improves `Get-GPOZaurrFiles`
  - ☑ Improves `Get-GPOZaurrNetLogon`
  - ☑ Fix for `Get-GPOZaurrNetLogon`
## 0.0.84 - 16.11.2020
  - ☑ Improves `Invoke-GPOZaurr` (WIP)
    - ☑ Type `NetLogonPermissions`
  - ☑ Fix for `Get-GPOZaurrNetLogon`
## 0.0.83 - 14.11.2020
  - ☑ Improves `Invoke-GPOZaurr` (WIP)
    - ☑ Fix for wrong ActionRequired count
## 0.0.82 - 14.11.2020
  - ☑ Added `Get-GPOZaurrPermissionIssue` to detect permission issue with no rights
  - ☑ Improves `Invoke-GPOZaurr` (WIP)
    - ☑ Type `GPOPermissionsRead` improved detection of problems with low permissions
## 0.0.81 - 12.11.2020
  - ☑ Fix for `Set-GPOZaurrOwner` in case of missing permissions to not throw errors
  - ☑ Improves `Invoke-GPOZaurr` (WIP)
    - ☑ Type `GPOPermissionsRead` added
## 0.0.80 - 12.11.2020
  - ☑ Improves `Invoke-GPOZaurr` (WIP)
    - ☑ Type `GPOOrphans` clearer options, updated texts, split per domain
    - ☑ Type `GPOOwners` clearer options, updated texts, split per domain
  - ☑ Improves `Add-GPOZaurrPermission`
    - ☑ Fixes LimitProcessing to work correctly
    - ☑ Added `All` to process all GPOs
  - ☑ Fixes `Remove-GPOZaurrPermission`
  - ☑ Improves `Set-GPOZaurrOwner`
    - ☑ Added `Force` to force `GPO Owner` to any principal (normally only Domain Admins)
## 0.0.79 - 10.11.2020
  - Improved `Invoke-GPOZaurr` - type `GPOOrphans`
## 0.0.78 - 10.11.2020
  - Improved `Remove-GPOZaurrBroken` more verbose
  - Improved `Get-GPOZaurrBroken` more verbose
  - Improved `Invoke-GPOZaurr` - type `GPOOrphans`
  - Improved `Invoke-GPOZaurr` - type `GPOList` - needs more work
  - Improved `Get-GPOZaurr` with better detection of Empty Policies (needs testing)
## 0.0.77 - 9.11.2020
  - Improved `Invoke-GPOZaurr` (WIP)
## 0.0.76 - 8.11.2020
  - Improved `Get-GPOZaurrNetLogon` to better handle errors
## 0.0.75 - 8.11.2020
  - Improved `Get-GPOZaurrPermissionConsistency` to stop checking consistency if path doesn't exists
## 0.0.74 - 8.11.2020
  - Improved `Invoke-GPOZaurr` (WIP)
## 0.0.73 - 7.11.2020
  - Improved `Invoke-GPOZaurr` (WIP)
  - Improved `Get-GPOZaurr`
## 0.0.72 - 6.11.2020
  - Improved `Invoke-GPOZaurr` (WIP)
## 0.0.71 - 3.11.2020
  - Improved `Invoke-GPOZaurr` (WIP)
## 0.0.70 - 29.10.2020
  - Added `Get-GPOZaurrDuplicateObject`
  - Added `Remove-GPOZaurrDuplicateObject`
## 0.0.69 - 29.10.2020
  - Improved `Invoke-GPOZaurr` (WIP)
  - Improved `Get-GPOZaurrNetLogon`
  - Improved `Get-GPOZaurrOwner`
  - Improved `Set-GPOZaurrOwner`
  - Added `Repair-GPOZaurrNetLogonOwner`
  - Improved `Invoke-GPOZaurr` (WIP)
## 0.0.68 - 28.10.2020
  - Renamed `Show-GPOZaurr` to `Invoke-GPOZaurr`
  - Renamed `Invoke-GPOZaurr` to `Invoke-GPOZaurrContent`
  - Improvements to `Get-GPOZaurrPermissionConsistency` - don't check for inherited permissions if top level ones are inconsistent
  - Improved `Invoke-GPOZaurr` (WIP)
## 0.0.67 - 22.10.2020
  - Improved `Show-GPOZaurr` (WIP)
## 0.0.66 - 22.10.2020
  - Improved `Show-GPOZaurr` (WIP)
## 0.0.65 - 22.10.2020
  - Improved `Show-GPOZaurr` (WIP)
## 0.0.64 - 21.10.2020
  - Renamed `Remove-GPOZaurrOrphaned` to `Remove-GPOZaurrBroken` keeping it as an alias
  - Renamed `Get-GPOZaurrSysvol` to `Get-GPOZaurrBroken` keeping it as an alias
  - Improved `Show-GPOZaurr` (WIP)
## 0.0.63 - 19.10.2020
  - Renamed `Invoke-GPOZaurrContent` back to `Invoke-GPOZaurr`
  - Added `Show-GPOZaurr` (WIP)
  - Added `OutputType`,`OutputType`,`Open`,`Online` parameters to `Invoke-GPOZaurr`
  - Added `Get-GPOZaurrNetLogon`
  - Improved `Get-GPOZaurrOwner`
  - Fixes `Get-GPOZaurrSysvol`
## 0.0.62 - 14.10.2020
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
## 0.0.61 - 31.08.2020
  - Improvement to `Get-GPOZaurrPermissionSummary`
  - Fixes to `ConvertFrom-CSExtension`
  - Fixes to `Find-CSExtension`
## 0.0.59 - 26.08.2020
  - Improvement to `Get-GPOZaurrPermissionSummary`
## 0.0.58 - 26.08.2020
  - Improvement to `Get-GPOZaurrPermissionSummary`
## 0.0.57 - 26.08.2020
  - Improvement to `Get-GPOZaurrPermissionSummary`
## 0.0.56 - 26.08.2020
  - Added `Get-GPOZaurrPermissionSummary`
## 0.0.55 - 17.08.2020
  - Improved `Get-GPOZaurrInheritance`
## 0.0.54 - 16.08.2020
  - Added `Invoke-GPOZaurrSupport` (WIP)
  - Added `ConvertFrom-CSExtension`
  - Added `Find-CSExtension`
  - Added `Get-GPOZaurrInheritance`
## 0.0.53 - 16.08.2020
  - Bad release
## 0.0.52 - 16.08.2020
  - Bad release
## 0.0.51 - 2.08.2020
  - Updates to `Invoke-GPOZaurr` - still work in progress
  - Added `Get-GPOZaurrSysvolDFSR`
  - Added `Clear-GPOZaurrSysvolDFSR` (requires testing)
## 0.0.50 - 29.07.2020
  - Updates to couple of commands
## 0.0.49 - 23.07.2020
  - Hidden files were skipped - and people do crazy things with them
## 0.0.48 - 21.07.2020
  - Added `Get-GPOZaurrFilesPolicyDefinition`
  - Updates to `Invoke-GPOZaurr` - still work in progress
  - Updates to `Get-GPOZaurrFiles` - still work in progress
  - Updates to `Remove-GPOZaurrOrphanedSysvolFolders` with backup and support for domains
  - Module will now be signed
## 0.0.47 - 29.06.2020
  - Update to `Get-GPOZaurrAD` for better error reporting
  - Updates to `Invoke-GPOZaurr` - still work in progress
## 0.0.46 - 28.06.2020
  - Additional protection for `Get-GPOZaurrAD` for CNF duplicates
  - Update to `Save-GPOZaurrFiles`
  - Added `Invoke-GPOZaurr` (alias: `Find-GPO`) (heavy work in progress)
## 0.0.45 - 26.06.2020
  - During publishing ADEssentials required functions are now merged to prevent cyclic dependency bug [Using ModuleSpec syntax in RequiredModules causes incorrect "cyclic dependency" failures](https://github.com/PowerShell/PowerShell/issues/2607)
## 0.0.44 - 24.06.2020
  - Improvement to `Get-GPOZaurrLinkSummary`
## 0.0.43 - 21.06.2020
  - Added `Get-GPOZaurrFiles` to list files on NETLOGON/SYSVOL shares with a lot of details
## 0.0.42 - 19.06.2020
  - Fix for `Get-GPOZaurrLink` and `SearchBase` parameter
  - Fix for `Get-GPOZaurrLink` - canonical link Trim() throwing errors if empty
## 0.0.41 - 18.06.2020
  - Added paramerter `SkipDuplicates` to `Invoke-GPOZaurrPermission` which prevents applying permissions over and over again if 1 GPO is linked to a multiple OU's within another OU
## 0.0.40 - 18.06.2020
  - Fix for error `Get-GPOZaurrLink` - same issue as described on my [earlier blog - Get-ADObject : The server has returned the following error: invalid enumeration context.](https://evotec.xyz/get-adobject-the-server-has-returned-the-following-error-invalid-enumeration-context/).
    - `WARNING: Get-GPOZaurrLink - Processing error The server has returned the following error: invalid enumeration context.`
    - `WARNING: Get-GPOZaurrLink - Processing error A referral was returned from the server`
  - Added `SkipDuplicates` for `Get-GPOZaurrLink`
## 0.0.39 - 17.06.2020
  - Updates to `Invoke-GPOZaurrPermission` with new parameter `LimitAdministrativeGroupsToDomain`
    - This will get administrative based on IncludeDomains if given. It means that if GPO has Domain admins added from multiple domains it will only find one, and remove all other Domain Admins (if working with Domain Admins that is)
## 0.0.38 - 17.06.2020
  - Update to Get-PrivGPOZaurrLink which would cause problems to `Invoke-GPOZaurrPermission` if it would be run without Administrative permission and GPO wouldn't be accessible for that user
## 0.0.37 - 16.06.2020
  - Updates to `Invoke-GPOZaurrPermission` with new parameterset `Level`
  - Updates to `Get-GPOZaurrLinkSummary`
## 0.0.36 - 15.06.2020
  - Initial release
