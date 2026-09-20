---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Repair-GPOZaurrPermissionConsistency
## SYNOPSIS
Repairs permission consistency for Group Policy Objects (GPOs) in a specified domain or forest.

## SYNTAX
### Default (Default)
```powershell
Repair-GPOZaurrPermissionConsistency [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-LimitProcessing <int>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### GPOName
```powershell
Repair-GPOZaurrPermissionConsistency [-GPOName <string>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-LimitProcessing <int>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### GPOGUID
```powershell
Repair-GPOZaurrPermissionConsistency [-GPOGuid <string>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-LimitProcessing <int>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Repair-GPOZaurrPermissionConsistency function repairs permission consistency for GPOs in a specified domain or forest. It checks for inconsistencies in GPO permissions and attempts to make them consistent.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Repair-GPOZaurrPermissionConsistency -GPOName "ExampleGPO" -Forest "example.com"
Repairs permission consistency for the GPO named "ExampleGPO" in the "example.com" forest.
```


### EXAMPLE 2
```powershell
PS > Repair-GPOZaurrPermissionConsistency -GPOGuid "12345678-1234-1234-1234-1234567890AB" -ExcludeDomains @("domain1", "domain2") -LimitProcessing 5
Repairs permission consistency for the GPO with the specified GUID, excluding domains "domain1" and "domain2", and processing a maximum of 5 GPOs.
```


## PARAMETERS

### -ExcludeDomains
Specifies an array of domains to exclude from the repair process.

```yaml
Type: String[]
Parameter Sets: Default, GPOName, GPOGUID
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Specifies additional information about the forest.

```yaml
Type: IDictionary
Parameter Sets: Default, GPOName, GPOGUID
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Specifies the forest where the GPOs are located.

```yaml
Type: String
Parameter Sets: Default, GPOName, GPOGUID
Aliases: ForestName
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOGuid
Specifies the GUID of the GPO to repair.

```yaml
Type: String
Parameter Sets: GPOGUID
Aliases: GUID, GPOID
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
Specifies the name of the GPO to repair.

```yaml
Type: String
Parameter Sets: GPOName
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Specifies an array of domains to include in the repair process.

```yaml
Type: String[]
Parameter Sets: Default, GPOName, GPOGUID
Aliases: Domain, Domains
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LimitProcessing
Specifies the maximum number of GPOs to process.

```yaml
Type: Int32
Parameter Sets: Default, GPOName, GPOGUID
Aliases: None
Possible values:

Required: False
Position: named
Default value: 2147483647
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
