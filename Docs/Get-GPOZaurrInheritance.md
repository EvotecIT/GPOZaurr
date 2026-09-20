---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrInheritance
## SYNOPSIS
Retrieves inheritance information for Group Policy Objects (GPOs) within specified Organizational Units (OUs).

## SYNTAX
### __AllParameterSets
```powershell
Get-GPOZaurrInheritance [[-Exclusions] <string[]>] [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [-IncludeBlockedObjects] [-OnlyBlockedInheritance] [-IncludeExcludedObjects] [-IncludeGroupPoliciesForBlockedObjects] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves and displays inheritance information for GPOs within specified OUs. It provides details on blocked inheritance, excluded objects, and group policies associated with blocked objects.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > $Objects = Get-GPOZaurrInheritance -IncludeBlockedObjects -IncludeExcludedObjects -OnlyBlockedInheritance -Exclusions $ExcludedOU
$Objects | Format-Table
```


## PARAMETERS

### -ExcludeDomains
Specifies the domain to exclude from the search. By default, the entire forest is scanned.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exclusions
Specifies the OUs approved by IT to be excluded. You can provide OUs by canonical name or distinguishedName.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Allows providing Forest Information from another command to speed up processing.

```yaml
Type: IDictionary
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Specifies the target forest. By default, the current forest is used.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: ForestName
Possible values:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeBlockedObjects
Specifies whether to include OUs with blocked inheritance. By default, this is disabled.

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

### -IncludeDomains
Specifies specific domains to include. By default, the entire forest is scanned.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: Domain, Domains
Possible values:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeExcludedObjects
Specifies whether to show excluded objects. By default, this is disabled.

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

### -IncludeGroupPoliciesForBlockedObjects
Specifies whether to include Group Policies for blocked objects. By default, this is disabled.

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

### -OnlyBlockedInheritance
Specifies whether to show only OUs with blocked inheritance.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

- `None`

## OUTPUTS

- `None`

## RELATED LINKS

- None
