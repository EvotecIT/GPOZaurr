---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Clear-GPOZaurrSysvolDFSR
## SYNOPSIS
Clears the ConflictAndDeleted folder in DFSR for specified GPOs.

## SYNTAX
### __AllParameterSets
```powershell
Clear-GPOZaurrSysvolDFSR [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-ExcludeDomainControllers] <string[]>] [[-IncludeDomains] <string[]>] [[-IncludeDomainControllers] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [[-LimitProcessing] <int>] [-SkipRODC] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function clears the ConflictAndDeleted folder in DFSR for specified Group Policy Objects (GPOs) within a given forest. It allows excluding specific domains and domain controllers if needed.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Clear-GPOZaurrSysvolDFSR -Forest "contoso.com" -IncludeDomains "child.contoso.com" -ExcludeDomainControllers "dc1.contoso.com" -SkipRODC
Clears the ConflictAndDeleted folder in DFSR for GPOs in the "contoso.com" forest, including only the "child.contoso.com" domain and excluding the "dc1.contoso.com" domain controller.
```


### EXAMPLE 2
```powershell
PS > Clear-GPOZaurrSysvolDFSR -Forest "contoso.com" -IncludeDomains "child.contoso.com" -LimitProcessing 5
Clears the ConflictAndDeleted folder in DFSR for GPOs in the "contoso.com" forest, including only the "child.contoso.com" domain, and processes a maximum of 5 GPOs.
```


## PARAMETERS

### -ExcludeDomainControllers
Specifies an array of domain controllers to exclude from the cleanup process.

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

### -ExcludeDomains
Specifies an array of domains to exclude from the cleanup process.

```yaml
Type: String[]
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
Specifies additional forest information if needed.

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
Specifies the forest name where the GPOs are located.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: ForestName
Possible values:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomainControllers
Specifies an array of domain controllers to include in the cleanup process.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: DomainControllers
Possible values:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Specifies an array of domains to include in the cleanup process.

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
Position: 6
Default value: 2147483647
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipRODC
Indicates whether Read-Only Domain Controllers (RODCs) should be skipped during cleanup.

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
