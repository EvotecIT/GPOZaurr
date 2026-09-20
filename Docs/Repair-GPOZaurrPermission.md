---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Repair-GPOZaurrPermission
## SYNOPSIS
Repairs permissions for Group Policy Objects (GPOs) based on specified criteria.

## SYNTAX
### __AllParameterSets
```powershell
Repair-GPOZaurrPermission [-Type] <string[]> [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [[-LimitProcessing] <int>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Repair-GPOZaurrPermission function repairs permissions for GPOs based on the specified criteria. It analyzes the permissions of GPOs and adds necessary permissions if they are missing.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Repair-GPOZaurrPermission -Type 'All' -Forest 'ContosoForest' -IncludeDomains @('Domain1', 'Domain2') -ExcludeDomains @('Domain3') -ExtendedForestInformation $info -LimitProcessing 100
Repairs permissions for all types of users in the 'ContosoForest' forest, including only 'Domain1' and 'Domain2' while excluding 'Domain3', with extended forest information and processing a maximum of 100 GPOs.
```


## PARAMETERS

### -ExcludeDomains
Specifies an array of domains to exclude from the analysis.

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

### -ExtendedForestInformation
Specifies additional information about the forest.

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
Specifies the forest name to analyze GPO permissions.

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

### -IncludeDomains
Specifies an array of domains to include in the analysis.

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

### -LimitProcessing
Specifies the maximum number of GPOs to process.

```yaml
Type: Int32
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 5
Default value: 2147483647
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Specifies the type of permissions to repair. Valid values are 'AuthenticatedUsers', 'Unknown', 'System', 'Administrative', and 'All'.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: AuthenticatedUsers, Unknown, System, Administrative, All

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
