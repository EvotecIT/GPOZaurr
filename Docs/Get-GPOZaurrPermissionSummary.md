---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrPermissionSummary
## SYNOPSIS
Retrieves a summary of Group Policy Object (GPO) permissions based on specified criteria.

## SYNTAX
### __AllParameterSets
```powershell
Get-GPOZaurrPermissionSummary [[-Type] <string[]>] [[-PermitType] <string>] [[-IncludePermissionType] <string[]>] [[-ExcludePermissionType] <string[]>] [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [[-Separator] <string>] [<CommonParameters>]
```

## DESCRIPTION
Retrieves a summary of GPO permissions based on the specified criteria, including filtering by permission types, permit types, and more.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrPermissionSummary -Type 'All' -PermitType 'Allow' -IncludePermissionType 'GpoApply', 'GpoEdit' -ExcludePermissionType 'GpoOwner' -Forest 'ExampleForest' -IncludeDomains 'Domain1', 'Domain2' -ExtendedForestInformation $ForestInfo -Separator '|'
```


### EXAMPLE 2
```powershell
PS > Get-GPOZaurrPermissionSummary -Type 'Administrative' -PermitType 'All' -IncludePermissionType 'GpoRead' -ExcludePermissionType 'GpoRootOwner' -Forest 'AnotherForest' -ExcludeDomains 'Domain3' -Separator ','
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
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludePermissionType
Specifies the permission types to exclude from the summary.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: GpoApply, GpoEdit, GpoCustom, GpoEditDeleteModifySecurity, GpoRead, GpoOwner, GpoRootCreate, GpoRootOwner

Required: False
Position: 3
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
Position: 7
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
Position: 4
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
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludePermissionType
Specifies the permission types to include in the summary.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: GpoApply, GpoEdit, GpoCustom, GpoEditDeleteModifySecurity, GpoRead, GpoOwner, GpoRootCreate, GpoRootOwner

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PermitType
Specifies the type of permission to permit. Options include 'Allow', 'Deny', and 'All'.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: Allow, Deny, All

Required: False
Position: 1
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -Separator
Specifies the separator to use in the output.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Specifies the type of permissions to include. Options include 'AuthenticatedUsers', 'DomainComputers', 'Unknown', 'WellKnownAdministrative', 'NotWellKnown', 'NotWellKnownAdministrative', 'NotAdministrative', 'Administrative', and 'All'.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: AuthenticatedUsers, DomainComputers, Unknown, WellKnownAdministrative, NotWellKnown, NotWellKnownAdministrative, NotAdministrative, Administrative, All

Required: False
Position: 0
Default value: All
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
