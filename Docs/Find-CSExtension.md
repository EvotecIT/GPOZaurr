---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Find-CSExtension
## SYNOPSIS
This function retrieves Group Policy Client Side Extensions (CSEs) from a specified Windows computer.

## SYNTAX
### __AllParameterSets
```powershell
Find-CSExtension [[-CSE] <string[]>] [[-ComputerName] <string>] [<CommonParameters>]
```

## DESCRIPTION
The Find-CSExtension function lists Group Policy Client Side Extensions (CSEs) configured on a Windows computer. It queries the Windows Registry to retrieve information about the CSEs.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Find-CSExtension -ComputerName "Computer01"
Retrieves all CSEs configured on the computer named "Computer01".
```


### EXAMPLE 2
```powershell
PS > Find-CSExtension -CSE "CSE1", "CSE2" -ComputerName "Computer02"
Retrieves information about CSEs named "CSE1" and "CSE2" on the computer named "Computer02".
```


## PARAMETERS

### -ComputerName
Specifies the name of the computer from which to retrieve the CSE information.

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

### -CSE
Specifies an array of CSE names to filter the results. If not provided, all CSEs will be listed.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

- `None`

## OUTPUTS

- `None`

## RELATED LINKS

- None
