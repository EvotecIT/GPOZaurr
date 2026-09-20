---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrPermissionRoot
## SYNOPSIS
Retrieves the root permissions of Group Policy Objects (GPOs) based on specified criteria.

## SYNTAX
### __AllParameterSets
```powershell
Get-GPOZaurrPermissionRoot [[-IncludePermissionType] <string[]>] [[-ExcludePermissionType] <string[]>] [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [-SkipNames] [<CommonParameters>]
```

## DESCRIPTION
Retrieves the root permissions of GPOs based on the specified criteria, including filtering by permission types, forest, domains, and more.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrPermissionRoot -IncludePermissionType 'GpoRootCreate' -ExcludePermissionType 'GpoRootOwner' -Forest 'ExampleForest' -IncludeDomains 'Domain1', 'Domain2' -ExtendedForestInformation $ForestInfo -SkipNames
```


### EXAMPLE 2
```powershell
PS > Get-GPOZaurrPermissionRoot -IncludePermissionType 'GpoRootOwner' -ExcludePermissionType 'GpoRootCreate' -Forest 'AnotherForest' -ExcludeDomains 'Domain3' -SkipNames
```


## PARAMETERS

### -ExcludeDomains
Specifies domains to exclude from the search.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludePermissionType
Specifies the root permission types to exclude from the search.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: GpoRootCreate, GpoRootOwner

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Provides additional forest information to speed up processing.

```yaml
Type: IDictionary
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 5
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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Specifies domains to include in the search.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: Domain, Domains
Possible values:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludePermissionType
Specifies the root permission types to include in the search.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: GpoRootCreate, GpoRootOwner

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipNames
Skips processing names during the operation.

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
