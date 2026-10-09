---
Module Name: GPOZaurr
Module Guid: f7d4c9e4-0298-4f51-ad77-e8e3febebbde
Download Help Link: https://github.com/EvotecIT/GPOZaurr
Help Version: 1.1.12
Locale: en-US
---
# GPOZaurr Module
## Description
Group Policy Eater is a PowerShell module that aims to gather information about Group Policies but also allows fixing issues that you may find in them.

## GPOZaurr Cmdlets
### [Add-GPOPermission](Add-GPOPermission.md)
{{ Fill in the Description }}

### [Add-GPOZaurrPermission](Add-GPOZaurrPermission.md)
{{ Fill in the Description }}

### [Backup-GPOZaurr](Backup-GPOZaurr.md)
Provides Backup functionality to Group Policies

### [Clear-GPOZaurrSysvolDFSR](Clear-GPOZaurrSysvolDFSR.md)
Clears the ConflictAndDeleted folder in DFSR for specified GPOs.

### [ConvertFrom-CSExtension](ConvertFrom-CSExtension.md)
Converts Client-side Extension (CSE) GUIDs to their corresponding names.

### [Export-GPOZaurrContent](Export-GPOZaurrContent.md)
Exports Group Policy Objects (GPOs) to XML or HTML files.

### [Find-CSExtension](Find-CSExtension.md)
This function retrieves Group Policy Client Side Extensions (CSEs) from a specified Windows computer.

### [Get-GPOZaurr](Get-GPOZaurr.md)
Gets information about all Group Policies. Similar to what Get-GPO provides by default.

### [Get-GPOZaurrAD](Get-GPOZaurrAD.md)
Retrieves Group Policy Objects (GPOs) information from Active Directory.

### [Get-GPOZaurrBackupInformation](Get-GPOZaurrBackupInformation.md)
Retrieves backup information from GPOZaurr manifest files.

### [Get-GPOZaurrBroken](Get-GPOZaurrBroken.md)
Detects broken or otherwise damaged Group Policies

### [Get-GPOZaurrBrokenLink](Get-GPOZaurrBrokenLink.md)
Finds any GPO link that doesn't have a matching GPO (already removed GPO).

### [Get-GPOZaurrDictionary](Get-GPOZaurrDictionary.md)
Retrieves a dictionary of Group Policy Objects (GPOs) with their associated types and paths.

### [Get-GPOZaurrDuplicateObject](Get-GPOZaurrDuplicateObject.md)
Retrieves duplicate Group Policy Objects (GPOs) within a specified forest.

### [Get-GPOZaurrFiles](Get-GPOZaurrFiles.md)
Retrieves information about Group Policy Objects (GPOs) stored in SYSVOL and NETLOGON folders.

### [Get-GPOZaurrFilesPolicyDefinition](Get-GPOZaurrFilesPolicyDefinition.md)
Retrieves policy definitions for Group Policy Objects (GPOs) within specified domains.

### [Get-GPOZaurrFolders](Get-GPOZaurrFolders.md)
Retrieves information about GPO folders within specified domains.

### [Get-GPOZaurrInheritance](Get-GPOZaurrInheritance.md)
Retrieves inheritance information for Group Policy Objects (GPOs) within specified Organizational Units (OUs).

### [Get-GPOZaurrLegacyFiles](Get-GPOZaurrLegacyFiles.md)
Retrieves legacy Group Policy Object (GPO) files from the SYSVOL directory of specified domains within a forest.

### [Get-GPOZaurrLink](Get-GPOZaurrLink.md)
Retrieves Group Policy Object (GPO) links based on specified criteria.

### [Get-GPOZaurrLinkSummary](Get-GPOZaurrLinkSummary.md)
Retrieves a summary of GPO links based on specified criteria.

### [Get-GPOZaurrMissingFiles](Get-GPOZaurrMissingFiles.md)
Retrieves information about missing files in Group Policy Objects (GPOs) within a specified forest.

### [Get-GPOZaurrNetLogon](Get-GPOZaurrNetLogon.md)
Retrieves information about Group Policy Objects (GPO) stored in the Netlogon and SYSVOL directories.

### [Get-GPOZaurrOrganizationalUnit](Get-GPOZaurrOrganizationalUnit.md)
Retrieves information about Group Policy Objects (GPOs) linked to Organizational Units (OUs) within a specified forest.

### [Get-GPOZaurrOwner](Get-GPOZaurrOwner.md)
Gets owners of GPOs from Active Directory and SYSVOL

### [Get-GPOZaurrPassword](Get-GPOZaurrPassword.md)
Tries to find CPassword in Group Policies or given path and translate it to readable value

### [Get-GPOZaurrPermission](Get-GPOZaurrPermission.md)
{{ Fill in the Description }}

### [Get-GPOZaurrPermissionAnalysis](Get-GPOZaurrPermissionAnalysis.md)
Analyzes permissions for Group Policy Objects (GPOs) and administrative groups.

### [Get-GPOZaurrPermissionConsistency](Get-GPOZaurrPermissionConsistency.md)
Retrieves information about Group Policy Objects (GPOs) and checks permission consistency across domains.

### [Get-GPOZaurrPermissionIssue](Get-GPOZaurrPermissionIssue.md)
Detects Group Policy missing Authenticated Users permission while not having higher permissions.

### [Get-GPOZaurrPermissionRoot](Get-GPOZaurrPermissionRoot.md)
Retrieves the root permissions of Group Policy Objects (GPOs) based on specified criteria.

### [Get-GPOZaurrPermissionSummary](Get-GPOZaurrPermissionSummary.md)
Retrieves a summary of Group Policy Object (GPO) permissions based on specified criteria.

### [Get-GPOZaurrRedirect](Get-GPOZaurrRedirect.md)
Command to detect if GPOs have correct path in SYSVOL, or someone changed it manually.

### [Get-GPOZaurrSysvolDFSR](Get-GPOZaurrSysvolDFSR.md)
Gets DFSR information from the SYSVOL DFSR

### [Get-GPOZaurrUpdates](Get-GPOZaurrUpdates.md)
Gets the list of GPOs created or updated in the last X number of days.

### [Get-GPOZaurrWMI](Get-GPOZaurrWMI.md)
Get Group Policy WMI filter

### [Invoke-GPOZaurr](Invoke-GPOZaurr.md)
Single cmdlet that provides 360 degree overview of Group Policies in Active Directory Forest.

### [Invoke-GPOZaurrContent](Invoke-GPOZaurrContent.md)
Invokes GPOZaurrContent function to retrieve Group Policy Objects information.

### [Invoke-GPOZaurrPermission](Invoke-GPOZaurrPermission.md)
{{ Fill in the Description }}

### [Invoke-GPOZaurrSupport](Invoke-GPOZaurrSupport.md)
Invokes GPOZaurrSupport function to retrieve Group Policy information.

### [New-GPOZaurrWMI](New-GPOZaurrWMI.md)
Creates a new WMI filter based on a WMI filter query.

### [Optimize-GPOZaurr](Optimize-GPOZaurr.md)
Enables or disables user/computer section of group policy based on it's content.

### [Remove-GPOPermission](Remove-GPOPermission.md)
{{ Fill in the Description }}

### [Remove-GPOZaurr](Remove-GPOZaurr.md)
Removes Group Policy Objects based on specified criteria.

### [Remove-GPOZaurrBroken](Remove-GPOZaurrBroken.md)
Finds and removes broken Group Policies from SYSVOL or AD or both.

### [Remove-GPOZaurrDuplicateObject](Remove-GPOZaurrDuplicateObject.md)
Removes duplicate Group Policy Objects (GPOs) identified by the Get-GPOZaurrDuplicateObject function.

### [Remove-GPOZaurrFolders](Remove-GPOZaurrFolders.md)
Removes specified GPOZaurr folders and backs them up to a specified path.

### [Remove-GPOZaurrLegacyFiles](Remove-GPOZaurrLegacyFiles.md)
Removes legacy Group Policy Objects (GPO) files from specified domains.

### [Remove-GPOZaurrLinkEmptyOU](Remove-GPOZaurrLinkEmptyOU.md)
Removes Group Policy Object (GPO) links from empty Organizational Units (OUs) in a specified forest.

### [Remove-GPOZaurrPermission](Remove-GPOZaurrPermission.md)
{{ Fill in the Description }}

### [Remove-GPOZaurrWMI](Remove-GPOZaurrWMI.md)
Removes Group Policy WMI filters based on specified criteria.

### [Repair-GPOZaurrBrokenLink](Repair-GPOZaurrBrokenLink.md)
Removes any link to GPO that no longer exists.

### [Repair-GPOZaurrNetLogonOwner](Repair-GPOZaurrNetLogonOwner.md)
Sets new owner to each file in NetLogon share.

### [Repair-GPOZaurrPermission](Repair-GPOZaurrPermission.md)
Repairs permissions for Group Policy Objects (GPOs) based on specified criteria.

### [Repair-GPOZaurrPermissionConsistency](Repair-GPOZaurrPermissionConsistency.md)
Repairs permission consistency for Group Policy Objects (GPOs) in a specified domain or forest.

### [Restore-GPOZaurr](Restore-GPOZaurr.md)
Restores Group Policy Objects (GPOs) from a specified backup folder.

### [Save-GPOZaurrFiles](Save-GPOZaurrFiles.md)
Exports GPO XML data to files and saves it to a given path

### [Set-GPOOwner](Set-GPOOwner.md)
Used within Invoke-GPOZaurrPermission only. Set new group policy owner.

### [Set-GPOZaurrOwner](Set-GPOZaurrOwner.md)
Sets GPO Owner to Domain Admins or other choosen account

### [Set-GPOZaurrStatus](Set-GPOZaurrStatus.md)
{{ Fill in the Description }}

### [Skip-GroupPolicy](Skip-GroupPolicy.md)
Used within ScriptBlocks only. Allows to exclude Group Policy from being affected by fixes
