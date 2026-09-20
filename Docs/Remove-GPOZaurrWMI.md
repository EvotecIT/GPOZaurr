---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Remove-GPOZaurrWMI
## SYNOPSIS
Removes Group Policy WMI filters based on specified criteria.

## SYNTAX
### __AllParameterSets
```powershell
Remove-GPOZaurrWMI [[-Guid] <guid[]>] [[-Name] <string[]>] [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function removes WMI filters based on the provided GUIDs or names within the specified forest or domains. It retrieves WMI filters associated with the GPOs and removes them.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Remove-GPOZaurrWMI -Guid "12345678-1234-1234-1234-123456789012"
```

Description
-----------
Removes the WMI filter with the specified GUID.

### EXAMPLE 2
```powershell
PS > Remove-GPOZaurrWMI -Name "TestWMIFilter"
```

Description
-----------
Removes the WMI filter with the specified name.

## PARAMETERS

### -ExcludeDomains
Specifies an array of domains to exclude from the removal process.

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

### -ExtendedForestInformation
Specifies additional information about the forest.

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
Specifies the forest name where the WMI filters are located.

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

### -Guid
Specifies an array of GUIDs of the WMI filters to be removed.

```yaml
Type: Guid[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Specifies an array of domains to include in the removal process.

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

### -Name
Specifies an array of names of the WMI filters to be removed.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

- `None`

## OUTPUTS

- `None`

## RELATED LINKS

- None
