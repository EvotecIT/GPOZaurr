---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version:
schema: 2.0.0
---

# Get-GPOZaurr

## SYNOPSIS
Gets information about all Group Policies.
Similar to what Get-GPO provides by default.

## SYNTAX

```
Get-GPOZaurr [[-ExcludeGroupPolicies] <ScriptBlock>] [[-GPOName] <String>] [[-GPOGuid] <String>]
 [[-Type] <String[]>] [[-Forest] <String>] [[-ExcludeDomains] <String[]>] [[-IncludeDomains] <String[]>]
 [[-ExtendedForestInformation] <IDictionary>] [[-GPOPath] <String[]>] [-PermissionsOnly] [-OwnerOnly]
 [-Limited] [[-ADAdministrativeGroups] <IDictionary>] [<CommonParameters>]
```

## DESCRIPTION
Gets information about all Group Policies.
Similar to what Get-GPO provides by default.

## EXAMPLES

### EXAMPLE 1
```
$GPOs = Get-GPOZaurr
```

$GPOs | Format-Table DisplayName, Owner, OwnerSID, OwnerType

### EXAMPLE 2
```
$GPO = Get-GPOZaurr -GPOName 'ALL | Allow use of biometrics'
```

$GPO | Format-List *

### EXAMPLE 3
```
$GPOS = Get-GPOZaurr -ExcludeGroupPolicies {
```

Skip-GroupPolicy -Name 'de14_usr_std'
    Skip-GroupPolicy -Name 'de14_usr_std' -DomaiName 'ad.evotec.xyz'
    Skip-GroupPolicy -Name 'All | Trusted Websites' #-DomaiName 'ad.evotec.xyz'
    '{D39BF08A-87BF-4662-BFA0-E56240EBD5A2}'
    'COMPUTERS | Enable Sets'
}
$GPOS | Format-Table -AutoSize *

## PARAMETERS

### -ExcludeGroupPolicies
Marks the GPO as excluded from the list.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
Provide a GPOName to get information about a specific GPO.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOGuid
Provide a GPOGuid to get information about a specific GPO.

```yaml
Type: String
Parameter Sets: (All)
Aliases: GUID, GPOID

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Choose a specific type of GPO.
Options are: 'Empty', 'Unlinked', 'Disabled', 'NoApplyPermission', 'All'.
Default is All.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Target different Forest, by default current forest is used

```yaml
Type: String
Parameter Sets: (All)
Aliases: ForestName

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDomains
Exclude domain from search, by default whole forest is scanned

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Include only specific domains, by default whole forest is scanned

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Domain, Domains

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Ability to provide Forest Information from another command to speed up processing

```yaml
Type: IDictionary
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOPath
Define GPOPath where the XML files are located to be analyzed instead of asking Active Directory

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PermissionsOnly
Only show permissions, by default all information is shown

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OwnerOnly
only show owner information, by default all information is shown

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limited
Provide limited output without analyzing XML data

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ADAdministrativeGroups
Ability to provide ADAdministrativeGroups from different function to speed up processing

```yaml
Type: IDictionary
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
