---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Remove-GPOZaurr
## SYNOPSIS
Removes Group Policy Objects based on specified criteria.

## SYNTAX
### __AllParameterSets
```powershell
Remove-GPOZaurr [-Type] <string[]> [[-ExcludeGroupPolicies] <scriptblock>] [-LimitProcessing <int>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-GPOPath <string[]>] [-BackupPath <string>] [-BackupDated] [-RequireDays <int>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Remove-GPOZaurr function removes Group Policy Objects (GPOs) based on the specified criteria. It allows for filtering by various parameters such as GPO type, forest, domains, and more.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Remove-GPOZaurr -Type 'Empty' -Forest 'Contoso' -IncludeDomains 'Domain1', 'Domain2' -BackupPath 'C:\GPOBackups' -BackupDated -RequireDays 7
Removes all empty GPOs from the 'Contoso' forest for 'Domain1' and 'Domain2', backs them up to 'C:\GPOBackups' with dated folders, and requires removal after 7 days.
```


### EXAMPLE 2
```powershell
PS > Remove-GPOZaurr -Type 'Disabled' -Forest 'Fabrikam' -ExcludeDomains 'Domain3' -LimitProcessing 10
Removes all disabled GPOs from the 'Fabrikam' forest excluding 'Domain3' and processes only the first 10 GPOs.
```


## PARAMETERS

### -BackupDated
Indicates whether the backup should be dated.

```yaml
Type: SwitchParameter
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupPath
Specifies the path for backing up GPOs before removal.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDomains
Specifies the domains to exclude from GPO removal.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeGroupPolicies
Specifies the Group Policies to exclude from removal.

```yaml
Type: ScriptBlock
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Specifies additional information about the forest.

```yaml
Type: IDictionary
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Specifies the forest to target for GPO removal.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: ForestName
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOPath
Specifies the path to the GPOs to be removed.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Specifies the domains to include for GPO removal.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: Domain, Domains
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LimitProcessing
Specifies the maximum number of GPOs to process before stopping.

```yaml
Type: Int32
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequireDays
Specifies the number of days before GPO removal is required.

```yaml
Type: Int32
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Specifies the type of GPOs to target for removal. Valid values are 'Empty', 'Unlinked', 'Disabled', 'NoApplyPermission'.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: Empty, Unlinked, Disabled, NoApplyPermission

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

- `None`

## OUTPUTS

- `None`

## RELATED LINKS

- None
