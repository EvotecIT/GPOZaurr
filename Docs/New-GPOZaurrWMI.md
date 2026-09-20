---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# New-GPOZaurrWMI
## SYNOPSIS
Creates a new WMI filter based on a WMI filter query.

## SYNTAX
### __AllParameterSets
```powershell
New-GPOZaurrWMI [-Name] <string> [[-Description] <string>] [[-Namespace] <string>] [-Query] <string> [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [-SkipQueryCheck] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function creates a new WMI filter in Active Directory based on a specified WMI filter query.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > New-GPOZaurrWMI -Name "TestWMIFilter1" -Query "SELECT * FROM Win32_OperatingSystem" -Force
Creates a new WMI filter named "TestWMIFilter1" targeting all Windows operating systems.
```


### EXAMPLE 2
```powershell
PS > New-GPOZaurrWMI -Name "TestWMIFilter2" -Query "SELECT * FROM Win32_Processor" -Forest "Contoso" -IncludeDomains "FinanceDomain"
Creates a new WMI filter named "TestWMIFilter2" targeting all processors in the "FinanceDomain" within the "Contoso" forest.
```


## PARAMETERS

### -Description
The description for the new WMI filter. Default is an empty string.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDomains
An array of domains to exclude from WMI application.

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

### -ExtendedForestInformation
Additional information about the forest for WMI customization.

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

### -Force
Switch to force the creation of the WMI entry without confirmation.

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

### -Forest
The forest to target for WMI creation.

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
An array of domains to include for WMI application.

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

### -Name
The name of the new WMI filter to be created.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Namespace
The WMI namespace to target. Default is 'root\CIMv2'.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 2
Default value: root\CIMv2
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query
The WMI filter query to be applied to the WMI entry.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipQueryCheck
Switch to skip the query check before creating the WMI entry.

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
