---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# ConvertFrom-CSExtension
## SYNOPSIS
Converts Client-side Extension (CSE) GUIDs to their corresponding names.

## SYNTAX
### __AllParameterSets
```powershell
ConvertFrom-CSExtension [[-CSE] <string[]>] [-Limited] [<CommonParameters>]
```

## DESCRIPTION
This function takes an array of CSE GUIDs and returns their corresponding names. It can be used to easily identify the purpose of each CSE GUID.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > ConvertFrom-CSExtension -CSE '{35378EAC-683F-11D2-A89A-00C04FBBCFA2}', '{0F6B957E-509E-11D1-A7CC-0000F87571E3}' -Limited
Converts the specified CSE GUIDs to their corresponding names, limited to a predefined set.
```


### EXAMPLE 2
```powershell
PS > ConvertFrom-CSExtension -CSE '{D02B1F73-3407-48AE-BA88-E8213C6761F1}', '{0ACDD40C-75AC-47ab-BAA0-BF6DE7E7FE63}'
Converts the specified CSE GUIDs to their corresponding names without any limitations.
```


## PARAMETERS

### -CSE
Specifies an array of Client-side Extension (CSE) GUIDs to be converted to names.

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

### -Limited
Indicates whether the conversion should be limited to a predefined set of CSE GUIDs.

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
