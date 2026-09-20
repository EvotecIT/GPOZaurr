---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrDictionary
## SYNOPSIS
Retrieves a dictionary of Group Policy Objects (GPOs) with their associated types and paths.

## SYNTAX
### __AllParameterSets
```powershell
Get-GPOZaurrDictionary [[-Splitter] <string>] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves a dictionary of Group Policy Objects (GPOs) along with their associated types and paths. It iterates through the GPOs stored in the $Script:GPODitionary variable and constructs a custom object for each GPO containing its name, types, and path.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrDictionary
Retrieves the dictionary of GPOs with their types and paths using the default newline delimiter.
```


### EXAMPLE 2
```powershell
PS > Get-GPOZaurrDictionary -Splitter ","
Retrieves the dictionary of GPOs with their types and paths using a comma as the delimiter.
```


## PARAMETERS

### -Splitter
Specifies the delimiter used to separate multiple types or paths. Default value is [System.Environment]::NewLine.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 0
Default value: [System.Environment]::NewLine
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
